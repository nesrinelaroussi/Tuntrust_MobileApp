import json
import re
from typing import List, Dict, Any
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

LISTING_URL = "https://tuntrust.tn/fr/content/nos-produits"
OUTPUT_FILE = "products.json"
HEADERS = {"User-Agent": "Mozilla/5.0"}


def clean_text(element: Any) -> str:
    if element is None:
        return ""
    text = " ".join(element.get_text(" ", strip=True).split())
    return re.sub(r"\s+", " ", text).strip()


def get_html(url: str) -> str:
    response = requests.get(url, headers=HEADERS, timeout=30, verify=False)
    response.raise_for_status()
    return response.text


def extract_product_links(html: str, base_url: str) -> List[str]:
    soup = BeautifulSoup(html, "html.parser")
    links: List[str] = []
    seen = set()

    for anchor in soup.select("article a[href], main a[href]"):
        href = anchor.get("href", "")
        if not href:
            continue

        full_url = urljoin(base_url, href)
        if "/nos-produits/" in full_url and full_url not in seen:
            seen.add(full_url)
            links.append(full_url)

    return links


def parse_title(soup: BeautifulSoup) -> str:
    title_tag = soup.select_one("h1.page-title") or soup.select_one("main article h1") or soup.select_one("h1")
    return clean_text(title_tag) if title_tag else ""


def parse_description(soup: BeautifulSoup) -> str:
    body_block = soup.select_one("main article .field--name-body") or soup.select_one("main article .field-name-body") or soup.select_one("main article") or soup.select_one("article")
    if not body_block:
        return ""

    paragraphs = [clean_text(p) for p in body_block.select("p") if clean_text(p)]
    return "\n".join(paragraphs)


def parse_features(soup: BeautifulSoup) -> List[str]:
    for heading in soup.select("h2, h3"):
        if "caractéristiques" in clean_text(heading).lower():
            features: List[str] = []
            current = heading.next_element
            while current:
                if getattr(current, "name", None) in {"h2", "h3"}:
                    break
                if getattr(current, "name", None) in {"p", "li"}:
                    text = clean_text(current)
                    if text and text not in features:
                        features.append(text)
                current = current.next_element
            if features:
                return features

    return []


def parse_image(soup: BeautifulSoup) -> str:
    article = soup.select_one("main article") or soup.select_one("article")
    if not article:
        return ""

    for img in article.select("img"):
        src = img.get("src")
        if src:
            return urljoin(LISTING_URL, src)

    return ""


def scrape_product(url: str) -> Dict[str, Any]:
    try:
        html = get_html(url)
        soup = BeautifulSoup(html, "html.parser")

        return {
            "name": parse_title(soup) or "",
            "description": parse_description(soup) or "",
            "features": parse_features(soup) or [],
            "image": parse_image(soup) or "",
            "url": url,
        }
    except requests.RequestException as exc:
        print(f"Warning: failed to scrape {url}: {exc}")
        return {
            "name": "",
            "description": "",
            "features": [],
            "image": "",
            "url": url,
        }


def scrape_products() -> List[Dict[str, Any]]:
    html = get_html(LISTING_URL)
    product_urls = extract_product_links(html, LISTING_URL)

    products: List[Dict[str, Any]] = []
    for product_url in product_urls:
        product = scrape_product(product_url)
        if not product["name"]:
            product["name"] = product_url.rsplit("/", 1)[-1].replace("-", " ").title()
        products.append(product)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as handle:
        json.dump(products, handle, ensure_ascii=False, indent=2)

    return products


if __name__ == "__main__":
    scraped = scrape_products()
    print(f"Scraped {len(scraped)} products")
    print(f"Saved to {OUTPUT_FILE}")
