from dataclasses import dataclass
import aiohttp
import asyncio
import pandas as pd
from bs4 import BeautifulSoup

url_base = "https://www.yourghoststories.com/real-ghost-story.php?story="

async def get_page_history(session, num: str):
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/129.0.0.0 Safari/537.36"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
    }
    try:
        async with session.get(url_base + num, headers= headers) as response:
            html = await response.text()
            soup = BeautifulSoup(html, "html.parser")

            story_div = soup.find("div", id="story")
            title = soup.find("h1", class_="storytitle")
            storyinfo_divs = soup.find_all("div", class_="storyinfo")

            if len(storyinfo_divs) < 2:
                return None

            info_div = storyinfo_divs[1]
            country_tag = info_div.find("a", href=lambda x: x and "ghost-stories-countries" in x)
            country = country_tag.get_text(strip=True) if country_tag else None

            category_tag = info_div.find("a", href=lambda x: x and "ghost-stories-categories" in x)
            category = category_tag.get_text(strip=True) if category_tag else None

            paragraphs = [p.get_text() for p in story_div.find_all("p") or []]
            
            return { 
                "title" : title.get_text() if title else "",
                "place" : country,
                "h_type" : category,
                "history" : "".join(paragraphs),
            }
    except asyncio.TimeoutError:
        return None

async def main(nums):
    async with aiohttp.ClientSession() as session:
        tasks = [get_page_history(session, str(num)) for num in nums]
        results = await asyncio.gather(*tasks)
        return results


results = asyncio.run(main([i for i in range(1, 20000)]))
clean_data = [res for res in results if res]
df = pd.DataFrame(clean_data)
df.to_csv("../data/histories.csv", sep=";", index=False, encoding="utf-8")

print(df)
