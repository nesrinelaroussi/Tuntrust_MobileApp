import asyncio
from crawl4ai import AsyncWebCrawler


async def main():

    async with AsyncWebCrawler() as crawler:

        result = await crawler.arun(
            url="https://tuntrust.tn"
        )

        with open(
            "data/tuntrust_home.md",
            "w",
            encoding="utf-8"
        ) as file:

            file.write(result.markdown)

        print("Saved successfully!")
        print("Characters:", len(result.markdown))


if __name__ == "__main__":
    asyncio.run(main())