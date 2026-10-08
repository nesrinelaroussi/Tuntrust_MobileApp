import os
import re
import glob
import hashlib

INPUT_FOLDER = "data"
OUTPUT_FOLDER = "clean_data"

# ============================================================
# 1. ENCODING & UNESCAPE
# ============================================================

def fix_encoding(text):
    """
    Fixes double-encoded UTF-8 / latin-1 mojibake characters if present,
    and normalizes non-breaking spaces.
    """
    try:
        fixed = text.encode("latin1").decode("utf-8")
        if fixed.count("Ã") + fixed.count("Â") < text.count("Ã") + text.count("Â"):
            text = fixed
    except (UnicodeEncodeError, UnicodeDecodeError):
        pass

    # Normalize non-breaking spaces
    text = text.replace("\u00a0", " ")
    
    # Replace escaped markdown backslashes for standard symbols
    replacements = [
        (r"\*", "*"),
        (r"\_", "_"),
        (r"\:", ":"),
        (r"\@", "@"),
        (r"\(", "("),
        (r"\)", ")"),
        (r"\[", "["),
        (r"\]", "]"),
        (r"\#", "#"),
    ]
    for old, new in replacements:
        text = text.replace(old, new)
        
    return text

# ============================================================
# 2. BOUNDARY DETECTION (HEADER & FOOTER CUTOFF)
# ============================================================

def detect_content_bounds(lines):
    """
    Locates the start and end indices of the actual page content block,
    stripping header navigation menus, hero banners, and footer noise.
    """
    # 1. Start line detection
    jump_link_indices = [
        i for i, line in enumerate(lines)
        if re.search(r'#pres|#cract|#tarifs|#demarche', line)
    ]
    
    if jump_link_indices:
        # Hero banner with jump links exists; main body starts after the last jump link
        last_jump = max(jump_link_indices)
        body_h1s = [
            i for i, line in enumerate(lines)
            if i > last_jump and line.strip().startswith("# ")
        ]
        start_idx = body_h1s[0] if body_h1s else last_jump + 1
    else:
        # Check H1 headers past line 30
        h1_indices = [
            i for i, line in enumerate(lines)
            if re.match(r'^#\s+\S+', line.strip())
        ]
        past_nav = [i for i in h1_indices if i >= 30]
        if past_nav:
            start_idx = past_nav[0]
        elif h1_indices:
            start_idx = h1_indices[0]
        else:
            # Fallback for pages without H1 (e.g. homepage)
            start_idx = 0
            for i, line in enumerate(lines):
                if i >= 40 and line.strip().startswith("##"):
                    start_idx = i
                    break

    # 2. End line detection (footer markers)
    footer_markers = [
        "## nos autres produits",
        "## les autres solutions",
        "## nos qualifications",
        "## menu principale",
        "## menu footer",
        "googleplus",
        "0 googleplus0",
        "100 googleplus0",
        "sharethis copy and paste"
    ]
    
    end_idx = len(lines)
    for i in range(start_idx + 1, len(lines)):
        l_str = lines[i].strip().lower()
        if any(marker in l_str for marker in footer_markers):
            end_idx = i
            break
            
    return start_idx, end_idx

# ============================================================
# 3. TABLE PROCESSING
# ============================================================

def clean_tables(lines):
    """
    Cleans markdown tables: merges cell rows split across lines and
    removes duplicate separator rows inside table bodies.
    """
    result = []
    i = 0
    in_table = False

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if "|" in stripped:
            # Header separator line or body separator line
            if re.fullmatch(r'\|?\s*[-:\s|]+\s*\|?', stripped):
                if not in_table:
                    result.append(line)
                    in_table = True
                # Skip extra separator rows inside body
                i += 1
                continue
                
            in_table = True
            
            # Check if current line and next line are split table cells
            if i + 1 < len(lines) and "|" in lines[i + 1]:
                next_stripped = lines[i + 1].strip()
                if (stripped.count("|") <= 2 and next_stripped.count("|") <= 2
                        and not next_stripped.startswith("| ---")):
                    line = line.rstrip(" |") + " | " + next_stripped.lstrip("| ").strip()
                    if not line.endswith("|"):
                        line += " |"
                    if not line.startswith("|"):
                        line = "| " + line
                    i += 1 # advance past next line
        else:
            in_table = False

        result.append(line)
        i += 1

    return result

# ============================================================
# 4. MAIN DOCUMENT CLEANING PROCESSOR
# ============================================================

def clean_text(raw_text):
    """
    Full document cleaning pipeline:
    1. Encoding repair
    2. Boundary extraction (strip header & footer)
    3. Heading repair (merge split headings)
    4. Image removal & link cleaning
    5. Table cleaning
    6. Deduplication & whitespace normalization
    """
    # 1. Encoding
    text = fix_encoding(raw_text)
    lines = text.splitlines()

    # 2. Extract content body boundaries
    start_idx, end_idx = detect_content_bounds(lines)
    body_lines = lines[start_idx:end_idx]

    # 3. Heading repair & element cleaning
    cleaned_lines = []
    i = 0

    while i < len(body_lines):
        line = body_lines[i].rstrip()
        stripped = line.strip()

        # Check for split headers where line is '#' or '##' or '###' and title is on next line
        if re.fullmatch(r'#+', stripped):
            if i + 1 < len(body_lines) and body_lines[i + 1].strip() and not body_lines[i + 1].strip().startswith('#'):
                hashes = stripped
                htext = body_lines[i + 1].strip()
                cleaned_lines.append(f"{hashes} {htext}")
                i += 2
                continue
            else:
                # Lone empty heading, skip
                i += 1
                continue

        # Skip pure image lines
        if re.fullmatch(r'!\[.*?\]\(.*?\)', stripped) or re.fullmatch(r'\[\s*!\[.*?\]\(.*?\)\s*\]\(.*?\)', stripped):
            i += 1
            continue

        # Strip embedded image tags inside text
        line = re.sub(r'!\[.*?\]\(.*?\)', '', line)
        line = re.sub(r'\[\s*!\[.*?\]\(.*?\)\s*\]\(.*?\)', '', line)

        # Skip jump menu anchor items like '* [Certificat ID-Trust](https://...#pres)'
        if re.match(r'^\s*[*|-]?\s*\[.*?\]\(.*?#.*?\)\s*$', line):
            i += 1
            continue

        # Skip empty link items '* [](https://...)'
        if re.match(r'^\s*[*|-]?\s*\[\s*\]\(.*?\)\s*$', line):
            i += 1
            continue

        # Skip navigation links like '[En savoir plus](...)'
        if 'en savoir plus' in line.lower() and re.search(r'\[.*?\]\(.*?\)', line):
            i += 1
            continue

        # Format bullet list markers consistently
        if re.match(r'^\s*\* ', line):
            line = re.sub(r'^\s*\* ', '  * ', line)
        elif re.match(r'^\s*- ', line):
            line = re.sub(r'^\s*- ', '  * ', line)

        cleaned_lines.append(line)
        i += 1

    # 4. Clean tables
    cleaned_lines = clean_tables(cleaned_lines)

    # 5. Remove consecutive duplicate lines & H1 repetitions
    final_lines = []
    prev_line = None

    for line in cleaned_lines:
        s = line.strip()

        # Skip consecutive duplicate line
        if s and s == prev_line:
            continue

        # Skip consecutive duplicate H1 title
        if s.startswith('# ') and prev_line and prev_line.startswith('# '):
            continue

        final_lines.append(line)
        if s:
            prev_line = s

    result = "\n".join(final_lines)
    # Normalize excessive blank lines
    result = re.sub(r'\n{3,}', '\n\n', result).strip()

    return result

# ============================================================
# 5. MAIN ENTRYPOINT & RUNNER
# ============================================================

def main():
    print("Starting TunTrust data cleaning pipeline...\n")

    os.makedirs(OUTPUT_FOLDER, exist_ok=True)

    if not os.path.exists(INPUT_FOLDER):
        print(f"ERROR: Input folder '{INPUT_FOLDER}' does not exist.")
        return

    processed_count = 0
    duplicate_count = 0
    empty_count = 0
    seen_hashes = {}

    input_files = sorted([
        f for f in os.listdir(INPUT_FOLDER)
        if f.lower().endswith(".md")
    ])

    print(f"Found {len(input_files)} Markdown files in '{INPUT_FOLDER}/'.\n")

    for filename in input_files:
        input_path = os.path.join(INPUT_FOLDER, filename)

        try:
            with open(input_path, "r", encoding="utf-8") as file:
                original = file.read()
        except Exception as error:
            print(f"ERROR reading {filename}: {error}")
            continue

        cleaned = clean_text(original)

        if not cleaned.strip():
            print(f"Skipped empty file: {filename}")
            empty_count += 1
            continue

        # Compute normalized hash for duplicate document detection
        norm_text = re.sub(r'\s+', ' ', cleaned.lower())
        doc_hash = hashlib.sha256(norm_text.encode("utf-8")).hexdigest()

        if doc_hash in seen_hashes:
            duplicate_count += 1
            print(f"Duplicate detected: {filename} (duplicate of {seen_hashes[doc_hash]})")
        else:
            seen_hashes[doc_hash] = filename

        output_path = os.path.join(OUTPUT_FOLDER, filename)

        with open(output_path, "w", encoding="utf-8") as file:
            file.write(cleaned)

        processed_count += 1
        print(f"Cleaned & written: {filename}")

    print("\n==========================================")
    print("TUNTRUST DATA CLEANING COMPLETE")
    print(f"  Processed files written to {OUTPUT_FOLDER}/ : {processed_count}")
    print(f"  Duplicate documents detected            : {duplicate_count}")
    print(f"  Empty files skipped                     : {empty_count}")
    print("==========================================\n")

if __name__ == "__main__":
    main()