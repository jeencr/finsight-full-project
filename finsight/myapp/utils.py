# news/utils.py
import feedparser
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import urllib.robotparser as robotparser

BASE = "https://www.ft.com"
RSS_URL = "https://www.ft.com/?format=rss"
SECTION_PATH = "/world"
HEADERS = {"User-Agent": "FTNewsScraper/1.0 (+https://example.com)"}

def fetch_rss(url=RSS_URL):
    feed = feedparser.parse(url)
    items = []
    for entry in feed.entries:
        items.append({
            "title": entry.get("title"),
            "link": entry.get("link"),
            "summary": entry.get("summary", ""),
            "published": entry.get("published", "")
        })
    return items

def can_fetch(url, user_agent=HEADERS["User-Agent"]):
    rp = robotparser.RobotFileParser()
    rp.set_url(urljoin(BASE, "/robots.txt"))
    try:
        rp.read()
    except Exception:
        return False
    return rp.can_fetch(user_agent, url)

def fetch_section_html(path=SECTION_PATH):
    url = urljoin(BASE, path)
    if not can_fetch(url):
        raise RuntimeError(f"Fetching disallowed by robots.txt: {url}")
    r = requests.get(url, headers=HEADERS, timeout=15)
    r.raise_for_status()
    return r.text

def parse_ft_list(html):
    soup = BeautifulSoup(html, "html.parser")
    articles = []
    for tag in soup.select("article, .o-teaser, .js-teaser__link"):
        a = tag.find("a")
        if not a or not a.get("href"):
            continue
        link = a["href"]
        if link.startswith("/"):
            link = urljoin(BASE, link)
        title = (a.get_text(strip=True) or tag.get_text(strip=True))[:400]
        summary_tag = tag.find("p")
        summary = summary_tag.get_text(strip=True) if summary_tag else ""
        articles.append({"title": title, "link": link, "summary": summary})
    return articles

def scrape_ft(include_html=False):
    """Fetch FT RSS + optionally HTML section."""
    rss_items = fetch_rss()
    result = rss_items
    if include_html:
        try:
            html = fetch_section_html()
            html_items = parse_ft_list(html)
            result += html_items
        except Exception:
            pass
    return result
