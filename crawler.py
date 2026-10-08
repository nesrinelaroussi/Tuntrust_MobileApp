import asyncio
import os
from crawl4ai import AsyncWebCrawler


urls = [

    "https://tuntrust.tn/fr/content/presentation",

    "https://tuntrust.tn/fr/content/nos-missions",

    "https://tuntrust.tn/fr/nos-produits/id-trust-certificat-dauthentification-et-de-signature",

    "https://tuntrust.tn/fr/nos-produits/cachet-electronique-enterprise-id",

    "https://tuntrust.tn/fr/nos-produits/cachet-electronique-visible-tn-cev-2d-doc",

    "https://tuntrust.tn/fr/nos-produits/organisation-ssl",

    "https://tuntrust.tn/fr/nos-produits/wildcard-ssl",

    "https://tuntrust.tn/fr/nos-produits/san-ssl",

    "https://tuntrust.tn/fr/nos-produits/certificat-signature-de-code",

    "https://tuntrust.tn/fr/nos-produits/certificat-vpn",

    "https://tuntrust.tn/fr/solutions/tunsign",

    "https://tuntrust.tn/fr/solutions/cev",

    "https://tuntrust.tn/fr/solutions/digigo",

    "https://tuntrust.tn/fr/solutions/tunstamp"

]


output_folder = "data"


os.makedirs(
    output_folder,
    exist_ok=True
)



def fix_encoding(text):

    """
    Fix corrupted characters like:
    d├®livr├® -> délivré
    s├®curit├® -> sécurité
    """

    try:
        text = text.encode(
            "latin1"
        ).decode(
            "utf-8"
        )

    except Exception:
        pass


    return text




async def main():

    async with AsyncWebCrawler() as crawler:


        for index, url in enumerate(urls):


            print(
                "\nCrawling:",
                url
            )


            result = await crawler.arun(

                url=url,

                word_count_threshold=20,

                excluded_tags=[

                    "nav",

                    "header",

                    "footer",

                    "script",

                    "style"

                ]

            )



            if result.success:


                content = result.markdown


                # Fix encoding problem
                content = fix_encoding(
                    content
                )


                filename = os.path.join(

                    output_folder,

                    f"page_{index}.md"

                )


                with open(

                    filename,

                    "w",

                    encoding="utf-8"

                ) as file:


                    file.write(
                        content
                    )



                print(
                    "Saved:",
                    filename
                )



            else:

                print(
                    "Failed:",
                    url
                )





if __name__ == "__main__":

    asyncio.run(main())