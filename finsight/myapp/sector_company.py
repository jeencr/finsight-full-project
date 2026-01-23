import time
import random
from nsepython import nsefetch
import pandas as pd
import yfinance as yf
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from GoogleNews import GoogleNews
from textblob import TextBlob

analyzer = SentimentIntensityAnalyzer()


def get_sector_companies(sector_index="NIFTY FMCG"):
    url = f"https://www.nseindia.com/api/equity-stockIndices?index={sector_index.replace(' ', '%20')}"
    data = nsefetch(url)
    df = pd.DataFrame(data["data"])
    return df["symbol"].tolist()



def get_fundamentals(symbol):
    ysym = symbol + ".NS"
    stock = yf.Ticker(ysym)
    info = stock.info or {}

    def safe(d, key, default=None):
        return d.get(key, default) if isinstance(d, dict) else default


    try:
        fcf = int(stock.cashflow.loc["Free Cash Flow"].iloc[0])
    except:
        fcf = None

    try:
        bal = stock.balance_sheet
        debt = int(bal.loc["Total Debt"].iloc[0])
        assets = int(bal.loc["Total Assets"].iloc[0])
        debt_assets = round(debt / assets, 3)
    except:
        debt_assets = None


    pe = safe(info, "trailingPE")
    earnings_growth = safe(info, "earningsGrowth")

    if pe is None or earnings_growth in [None, 0]:
        peg = None
    else:
        growth_percent = earnings_growth * 100
        peg = round(pe / growth_percent, 3)

    return {
        "Symbol": symbol,
        "Price": safe(info, "currentPrice"),
        "EPS": safe(info, "trailingEps"),
        "Revenue_TTM": safe(info, "totalRevenue"),
        "Net_Income": safe(info, "netIncomeToCommon"),
        "Free_Cash_Flow": fcf,
        "Debt_Assets": debt_assets,
        "PE": pe,
        "PEG": peg,
        "PS": safe(info, "priceToSalesTrailing12Months"),
        "PB": safe(info, "priceToBook"),
        "EPS_5yr_CAGR": earnings_growth,
        "Revenue_5yr_CAGR": safe(info, "revenueGrowth"),
    }



def get_company_news(query):

    time.sleep(random.uniform(1.5, 3.5))

    googlenews = GoogleNews(lang='en', period='7d')
    googlenews.search(query)

    results = googlenews.result()
    cleaned = []

    for item in results:
        title = item.get("title")
        link = item.get("link")

        if not title:
            continue

        sentiment = TextBlob(title).sentiment.polarity

        cleaned.append({
            "title": title,
            "url": link,
            "sentiment": sentiment
        })

    return cleaned


def calculate_score(f):
    score = 0

    peg = f.get("PEG")
    if peg is not None:
        if peg < 1:
            score += 20
        elif peg < 2:
            score += 10

    pe = f.get("PE")
    if pe is not None:
        if pe < 20:
            score += 20
        elif pe < 40:
            score += 10

    da = f.get("Debt_Assets")
    if da is not None:
        if da < 0.5:
            score += 20
        elif da < 1:
            score += 10

    fcf = f.get("Free_Cash_Flow")
    if fcf is not None and fcf > 0:
        score += 10

    sent = f.get("Avg_Sentiment", 0)
    if sent > 0.1:
        score += 30
    elif sent > -0.1:
        score += 15

    return score


def build_analysis_table(sector_name="NIFTY FMCG"):
    symbols = get_sector_companies(sector_name)
    output = []

    for sym in symbols:

        time.sleep(random.uniform(0.8, 2.2))

        fundamentals = get_fundamentals(sym)

        query = sym + " India stock"
        news_list = get_company_news(query)

        if news_list:
            avg_sent = sum(n["sentiment"] for n in news_list) / len(news_list)
        else:
            avg_sent = 0

        fundamentals["Avg_Sentiment"] = avg_sent
        fundamentals["News"] = news_list
        fundamentals["Score"] = calculate_score(fundamentals)

        output.append(fundamentals)

    return output
