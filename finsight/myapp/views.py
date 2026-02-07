from datetime import datetime
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.http import request
from django.shortcuts import render, redirect
from django.contrib.auth.models import User, Group

# Create your views here.
from myapp.models import *
from myapp.sector_company import build_analysis_table
from myapp.utils import scrape_ft
import os
import json
import base64
from io import BytesIO
import matplotlib.pyplot as plt
import mplfinance as mpf
import pandas as pd
import yfinance as yf
from datetime import datetime, timezone

from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.cache import never_cache

from myapp.sector_company import build_analysis_table


def login_page(request):
    return render(request, 'loginpage.html')


def ft_news_view(request):
    include_html = request.GET.get("html") == "1"
    articles = scrape_ft(include_html=include_html)
    return render(request, "ft_table.html", {"articles": articles})

import yfinance as yf
from django.shortcuts import render
from datetime import datetime, time

import yfinance as yf
from django.shortcuts import render
from datetime import datetime, time

from datetime import datetime, time
from django.shortcuts import render
import yfinance as yf


def _safe_last(df, column, default=0):
    if df is not None and not df.empty and column in df.columns:
        return round(df[column].iloc[-1], 2)
    return default


def _safe_change(df, default=0):
    if (
        df is not None
        and not df.empty
        and "Open" in df.columns
        and "Close" in df.columns
        and df["Open"].iloc[-1] != 0
    ):
        return round(
            ((df["Close"].iloc[-1] - df["Open"].iloc[-1]) / df["Open"].iloc[-1]) * 100,
            2,
        )
    return default

@login_required(login_url='/myapp/login_page/')

def admin_home(request):
    # =========================
    # INDEX DATA (SAFE)
    # =========================
    nifty_df = yf.Ticker("^NSEI").history(period="1d")
    sensex_df = yf.Ticker("^BSESN").history(period="1d")

    nifty_price = _safe_last(nifty_df, "Close")
    nifty_change = _safe_change(nifty_df)

    sensex_price = _safe_last(sensex_df, "Close")
    sensex_change = _safe_change(sensex_df)

    # =========================
    # STOCK DATA (SAFE)
    # =========================
    symbols = {
        "RELIANCE": "RELIANCE.NS",
        "TCS": "TCS.NS",
        "INFOSYS": "INFY.NS",
        "HDFC BANK": "HDFCBANK.NS",
    }

    stock_rows = []
    for name, symbol in symbols.items():
        df = yf.Ticker(symbol).history(period="1d")

        stock_rows.append({
            "name": name,
            "price": _safe_last(df, "Close"),
            "change": _safe_change(df),
        })

    # =========================
    # FOREX DATA (SAFE)
    # =========================
    forex_pairs = {
        "USD / INR": "USDINR=X",
        "EUR / USD": "EURUSD=X",
        "GBP / USD": "GBPUSD=X",
        "USD / JPY": "USDJPY=X",
    }

    forex_rows = []
    for name, symbol in forex_pairs.items():
        df = yf.Ticker(symbol).history(period="1d")

        forex_rows.append({
            "pair": name,
            "rate": _safe_last(df, "Close"),
            "change": _safe_change(df),
        })

    # =========================
    # MARKET STATUS
    # =========================
    now = datetime.now().time()
    market_open = time(9, 15)
    market_close = time(15, 30)
    market_status = "OPEN" if market_open <= now <= market_close else "CLOSED"

    context = {
        "nifty_price": nifty_price,
        "nifty_change": nifty_change,
        "sensex_price": sensex_price,
        "sensex_change": sensex_change,
        "market_status": market_status,
        "stocks": stock_rows,
        "forex": forex_rows,
    }

    return render(request, "admin/adminhome.html", context)



def loginpost(request):
    username = request.POST['email']
    password = request.POST['password']
    print(username,password)

    user = authenticate(request, username=username, password=password)
    if user is not None:
        if user.groups.filter(name="admin").exists():
            print("admin")
            login(request, user)
            return redirect('/myapp/admin_home')

        elif user.groups.filter(name='expert').exists():
            expert=Expert.objects.get(LOGIN=user)
            if expert.status=='accepted':

                print("expert")
                login(request,user)
                return redirect('/myapp/expert_home/')
            else :
                messages.warning(request,'user rejected')
                return redirect('/myapp/login_page')

        else:
            messages.warning(request, "invalid user")

            return redirect('/myapp/login_page')
    else:
        messages.warning(request, "invalid usename or password")
        return redirect('/myapp/login_page/')

def register(request):
    return render (request,"signup.html")

def register_post(request):
    specilization = request.POST['specilization']
    name = request.POST['name']
    photo = request.FILES['photo']
    experiance = request.POST['experiance']
    phone = request.POST['phone']
    email = request.POST['email']
    username = request.POST['username']
    password = request.POST['password']

    if User.objects.filter(username=username).exists():
        messages.warning(request, "user already exist")
        return redirect('/myapp/register/')
    else:
        user=User.objects.create_user(username=username,password=password)
        user.groups.add(Group.objects.get(name='expert'))
        expert=Expert()
        expert.name = name
        expert.specilization= specilization
        expert.photo= photo
        expert.experiance=experiance
        expert.phone=phone
        expert.email=email
        expert.status='pending'
        expert.LOGIN=user
        expert.save()
        return redirect('/myapp/login_page/')

@login_required(login_url='/myapp/login_page/')
def view_expert(request):
    experts=Expert.objects.all()
    return render(request,'admin/viewexpert.html',{"experts":experts})


def accept_expert(request,id):
    accept=Expert.objects.get(id=id)
    accept.status='accepted'
    accept.save()
    messages.success(request,'this expert accepted')
    return redirect('/myapp/viewexpert/')


def reject_expert(request,id):
    reject=Expert.objects.get(id=id)
    reject.status='rejected'
    reject.save()
    messages.success(request,'this expert rejected')
    return redirect('/myapp/viewexpert/')

@login_required(login_url='/myapp/login_page/')
def view_investers(request):
    investers=Investers.objects.all()
    return render(request,'admin/viewinvesters.html',{"investers":investers})


@login_required(login_url='/myapp/login_page/')
def view_feedback(request):
    viewfeedback=Feed_back.objects.all()
    return render(request,'admin/viewfeedback.html',{"viewfeedback":viewfeedback})


@login_required(login_url='/myapp/login_page/')
def view_complaints(request):
    viewcomplaints=Complaints.objects.all()
    return render(request,'admin/complaint.html',{"viewcomplaints":viewcomplaints})


@login_required(login_url='/myapp/login_page/')
def complaint_replay(request,id):
    viewcomplaints=Complaints.objects.all()
    comp=Complaints.objects.get(id=id)

    return render(request,'admin/complaint.html',{"complaintreplay":comp,"viewcomplaints":viewcomplaints})


def complaint_replay_post(request):
    if request.POST:
        comp_id = request.POST['comp_id']
        print(comp_id)
        comp = Complaints.objects.get(id=comp_id)
        print(comp)
        reply = request.POST['reply']
        print(request.POST['reply'])
        comp.replay = reply
        comp.save()
        return redirect('/myapp/viewcomplaints/')

@login_required(login_url='/myapp/login_page/')
def notification(request):
        return render(request, 'admin/notification.html' )

def notification_post(request):
    if request.POST:
        title=request.POST['title']
        description=request.POST['discription']
        comp = Notification()
        comp.title=title
        comp.description=description
        comp.date=datetime.now()
        comp.save()
        return redirect('/myapp/notification/')




@login_required(login_url='/myapp/login_page/')
def view_notification(request):
    viewnotification=Notification.objects.all()
    return render(request,'admin/viewnotification.html',{"viewnotification":viewnotification})

def delete_notification(request,id):
    deletenotification=Notification.objects.get(id=id)
    deletenotification.delete()
    return redirect('/myapp/view_notification/')
from datetime import datetime, time
from django.contrib.auth.decorators import login_required
from django.shortcuts import render
import yfinance as yf


def _safe_last(df, column, default=0):
    if df is not None and not df.empty and column in df.columns:
        return round(df[column].iloc[-1], 2)
    return default


def _safe_change(df, default=0):
    if (
        df is not None
        and not df.empty
        and "Open" in df.columns
        and "Close" in df.columns
        and df["Open"].iloc[-1] != 0
    ):
        return round(
            ((df["Close"].iloc[-1] - df["Open"].iloc[-1]) / df["Open"].iloc[-1]) * 100,
            2,
        )
    return default


@login_required(login_url='/myapp/login_page/')
def expert_home(request):
    # =========================
    # INDEX DATA (SAFE)
    # =========================
    nifty_df = yf.Ticker("^NSEI").history(period="1d")
    sensex_df = yf.Ticker("^BSESN").history(period="1d")

    nifty_price = _safe_last(nifty_df, "Close")
    nifty_change = _safe_change(nifty_df)

    sensex_price = _safe_last(sensex_df, "Close")
    sensex_change = _safe_change(sensex_df)

    # =========================
    # STOCK DATA (SAFE)
    # =========================
    symbols = {
        "RELIANCE": "RELIANCE.NS",
        "TCS": "TCS.NS",
        "INFOSYS": "INFY.NS",
        "HDFC BANK": "HDFCBANK.NS",
    }

    stock_rows = []
    for name, symbol in symbols.items():
        df = yf.Ticker(symbol).history(period="1d")

        stock_rows.append({
            "name": name,
            "price": _safe_last(df, "Close"),
            "change": _safe_change(df),
        })

    # =========================
    # FOREX DATA (SAFE)
    # =========================
    forex_pairs = {
        "USD / INR": "USDINR=X",
        "EUR / USD": "EURUSD=X",
        "GBP / USD": "GBPUSD=X",
        "USD / JPY": "USDJPY=X",
    }

    forex_rows = []
    for name, symbol in forex_pairs.items():
        df = yf.Ticker(symbol).history(period="1d")

        forex_rows.append({
            "pair": name,
            "rate": _safe_last(df, "Close"),
            "change": _safe_change(df),
        })

    # =========================
    # MARKET STATUS
    # =========================
    now = datetime.now().time()
    market_open = time(9, 15)
    market_close = time(15, 30)
    market_status = "OPEN" if market_open <= now <= market_close else "CLOSED"

    context = {
        "nifty_price": nifty_price,
        "nifty_change": nifty_change,
        "sensex_price": sensex_price,
        "sensex_change": sensex_change,
        "market_status": market_status,
        "stocks": stock_rows,
        "forex": forex_rows,
    }

    return render(request, 'expert/experthome.html', context)



@login_required(login_url='/myapp/login_page/')
def viewprofile(request):
    expertid=request.user.id
    viewprofile=Expert.objects.get(LOGIN_id=expertid)
    reqs = User_request.objects.filter(Expert__LOGIN_id=expertid)
    assignuser = Assgin_expert.objects.filter(Expert__LOGIN_id=expertid)
    return render(request,'expert/manageprofile.html',{"viewprofile":viewprofile,"reqs":reqs,"assignuser":assignuser})


@login_required(login_url='/myapp/login_page/')
def addcapital(request):
        return render(request, 'expert/add_capital.html' )

def add_capital(request):
    if request.POST:
        capital=request.POST['requierd_capital']
        returns=request.POST['returns']
        expertid = request.user.id
        id=Expert.objects.get(LOGIN_id=expertid)
        comp = Capital()
        comp.requierd_capital=capital
        comp.returns=returns
        comp.Expert=id
        comp.save()
    return redirect('/myapp/addcapital/')

@login_required(login_url='/myapp/login_page/')
def assigned_users(request):
    id=request.user.id
    expertid = Expert.objects.get(LOGIN_id=id)
    assignuser = Assgin_expert.objects.filter(Expert=expertid)
    return render(request, 'expert/assignuser.html', {"assign_user": assignuser})


@login_required(login_url='/myapp/login_page/')
def view_request_admin(request):
    reqs = User_request.objects.filter(status='pending')
    return render(request, 'admin/view_request.html', {"reqs": reqs})

def accept_request_post(request,id):
    req_id = id
    req = User_request.objects.get(id=req_id)
    req.status = 'accepted'
    if Assgin_expert.objects.filter(Investers=req.Investers).exists():
        messages.error(request, 'This user is already assigned to an expert')
        return redirect('/myapp/view_request_admin/')
    else:
        assign = Assgin_expert()
        assign.Expert = req.Expert
        assign.Investers = req.Investers
        assign.save()
        req.save()

        return redirect('/myapp/view_request_admin/')


def decline_request_post(request,id):
    req_id = id
    req = User_request.objects.get(id=req_id)
    req.status = 'declined'
    req.save()
    return redirect('/myapp/view_request_admin/')


def manage_tips(request):
    tips = Tips.objects.filter(Expert__LOGIN=request.user)

    if request.method == 'POST':
        tip = Tips()
        tip.Expert = Expert.objects.get(LOGIN=request.user)
        tip.company = request.POST['company']
        tip.sector = request.POST['sector']
        tip.recommendation = request.POST['recommendation']
        tip.tips = request.POST['tips']
        tip.description = request.POST['description']
        tip.save()
        return redirect('/myapp/manage_tips/')

    # Calculate counts for summary
    total_tips = tips.count()
    buy_tips = tips.filter(tips__in=['Buy', 'Strong Buy']).count()
    sell_tips = tips.filter(tips__in=['Sell', 'Strong Sell']).count()
    hold_tips = tips.filter(tips='Hold').count()

    return render(request, 'expert/manage_tips.html', {
        'tips': tips,
        'total_tips': total_tips,
        'buy_tips': buy_tips,
        'sell_tips': sell_tips,
        'hold_tips': hold_tips,
    })


from django.contrib.auth.models import User
from django.http import JsonResponse
import json
from datetime import datetime


def chatwithuser(request, id):
    expertid = request.user.id
    investerid = id
    messages = Chat.objects.filter(
        Q(from_id_id=investerid, to_id_id=expertid) | Q(from_id_id=expertid, to_id_id=investerid)
    ).order_by('date')

    # Get user information from User model
    try:
        user = User.objects.get(id=investerid)
        user_name = user.username  # or user.first_name, user.last_name
    except User.DoesNotExist:
        user_name = f"User {investerid}"

    return render(request, 'expert/chat.html', {
        "messages": messages,
        "id": investerid,
        "user_name": user_name,
        "expert_id": expertid,
    })


def get_chat_messages(request, id):
    if request.method == 'GET':
        expertid = request.user.id
        investerid = id

        try:
            # Check if last_id parameter is provided for polling
            last_id = request.GET.get('last_id', 0)

            messages = Chat.objects.filter(
                Q(from_id_id=investerid, to_id_id=expertid) | Q(from_id_id=expertid, to_id_id=investerid)
            )

            # If last_id is provided, only get messages newer than that
            if last_id:
                messages = messages.filter(id__gt=last_id)

            messages = messages.order_by('date')

            messages_list = []
            for chat in messages:
                messages_list.append({
                    "id": chat.id,
                    "message": chat.message,
                    "date": chat.date.strftime("%Y-%m-%d %H:%M:%S"),
                    "from_id": chat.from_id_id,
                    "to_id": chat.to_id_id,
                    "is_expert": chat.from_id_id == expertid,
                    "from_username": chat.from_id.username if chat.from_id else "Unknown",
                })

            return JsonResponse({
                "status": "success",
                "messages": messages_list,
                "expert_id": expertid,
                "user_id": investerid,
                "total": len(messages_list)
            })

        except Exception as e:
            return JsonResponse({
                "status": "error",
                "message": str(e)
            }, status=500)

    return JsonResponse({
        "status": "error",
        "message": "Invalid request method"
    }, status=405)


def chatwithuser_post(request, id):
    if request.method == 'POST':
        try:
            sender_id = request.user.id
            receiver_id = id
            message = request.POST.get('message', '').strip()

            # For AJAX requests with JSON data
            if not message and request.body:
                try:
                    data = json.loads(request.body)
                    message = data.get('message', '').strip()
                except json.JSONDecodeError:
                    pass

            if not sender_id or not receiver_id or not message:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Missing required fields.'
                }, status=400)

            try:
                # Use User model instead of Login
                sender = User.objects.get(id=sender_id)
                receiver = User.objects.get(id=receiver_id)
            except User.DoesNotExist:
                return JsonResponse({
                    'status': 'error',
                    'message': 'Invalid sender or receiver ID'
                }, status=400)

            # Create the chat message
            chat = Chat.objects.create(
                from_id=sender,
                to_id=receiver,
                message=message,
                date=datetime.now()
            )

            # Return success response with message details
            return JsonResponse({
                'status': 'success',
                'message': 'Message sent successfully',
                'chat_id': chat.id,
                'from_id': sender_id,
                'to_id': receiver_id,
                'message_text': message,
                'date': chat.date.strftime("%Y-%m-%d %H:%M:%S")
            })

        except Exception as e:
            return JsonResponse({
                'status': 'error',
                'message': str(e)
            }, status=500)

    return JsonResponse({
        'status': 'error',
        'message': 'Invalid request method'
    }, status=405)

def viewrequestexpert(request,id):
    reqs = User_request.objects.get(Investers_id=id,status='accepted')
    return render(request, 'expert/view_request.html', {"reqs": reqs})

import yfinance as yf
from django.shortcuts import render, redirect
from .models import Expert, User_request

import yfinance as yf
from django.shortcuts import render, redirect
from django.utils import timezone
from django.contrib import messages

from .models import Expert, Investers, UserPortfolio


def createportfolio(request, id):
    """
    GET PAGE
    Expert selects company and amount
    """
    companies = {
        "RELIANCE": "RELIANCE.NS",
        "TCS": "TCS.NS",
        "INFOSYS": "INFY.NS",
        "HDFC BANK": "HDFCBANK.NS",
        "ICICI BANK": "ICICIBANK.NS",
    }

    company_data = []

    for name, symbol in companies.items():
        try:
            data = yf.Ticker(symbol).history(period="1d")
            price = round(data["Close"].iloc[-1], 2)
        except Exception:
            price = 0.0

        company_data.append({
            "name": name,
            "symbol": symbol,
            "price": price,
        })

    context = {
        "id": id,                 # Investor ID
        "companies": company_data
    }

    return render(request, 'expert/createportfolio.html', context)


from django.shortcuts import redirect
from django.utils import timezone
from django.contrib import messages
import yfinance as yf

def createportfolio_post(request):
    """
    POST PAGE
    Saves portfolio using live price from yfinance
    Stores company symbol WITHOUT .NS in DB
    """
    if request.method == "POST":
        investor_id = request.POST.get("investor_id")
        company_name = request.POST.get("company")  # e.g. TCS, RELIANCE, HDFC BANK
        amount = float(request.POST.get("amount"))

        # =========================
        # BUILD YFINANCE SYMBOL
        # =========================
        # "HDFC BANK" -> "HDFCBANK.NS"
        yahoo_symbol = company_name.replace(" ", "").upper() + ".NS"

        # =========================
        # FETCH LIVE PRICE (SAFE)
        # =========================
        try:
            df = yf.Ticker(yahoo_symbol).history(period="1d")
            if df.empty:
                raise ValueError("No market data")
            live_price = round(df["Close"].iloc[-1], 2)
        except Exception:
            messages.error(request, "Unable to fetch live stock price.")
            return redirect('/myapp/createportfolio/' + investor_id)

        # =========================
        # CALCULATE STOCK QTY
        # =========================
        number_of_stocks = round(amount / live_price, 2) if live_price > 0 else 0

        # =========================
        # SAVE PORTFOLIO
        # =========================
        portfolio = UserPortfolio()
        portfolio.Expert = Expert.objects.get(LOGIN=request.user)
        portfolio.Investers = Investers.objects.get(id=investor_id)

        portfolio.company = yahoo_symbol.replace(".NS", "")  # e.g. TCS, HDFCBANK

        portfolio.date = timezone.now().strftime("%Y-%m-%d %H:%M")
        portfolio.price_per_stock_when_bought = str(live_price)
        portfolio.number_of_stocks = str(number_of_stocks)
        portfolio.save()

        messages.success(request, "Portfolio created successfully.")

        return redirect('/myapp/createportfolio/' + investor_id)

#####core#####
@login_required(login_url='/myapp/login_page/')
def view_company_fundamental(request):
    sector = request.GET.get("sector", "NIFTY AUTO")
    rec_filter = request.GET.get("rec", "")
    data = build_analysis_table(sector)
    data = sorted(data, key=lambda x: x.get("Score", 0), reverse=True)

    # Calculate recommendations
    for item in data:
        score = item.get("Score", 0)
        if score >= 80:
            item["Recommendation"] = "Strong Buy"
        elif score >= 60:
            item["Recommendation"] = "Buy"
        elif score >= 40:
            item["Recommendation"] = "Hold"
        else:
            item["Recommendation"] = "Avoid"

    # Apply filter if selected
    if rec_filter:
        data = [d for d in data if d.get("Recommendation") == rec_filter]

    # Calculate counts for display
    counts = {
        'strong_buy': len([d for d in data if d.get('Recommendation') == 'Strong Buy']),
        'buy': len([d for d in data if d.get('Recommendation') == 'Buy']),
        'hold': len([d for d in data if d.get('Recommendation') == 'Hold']),
        'avoid': len([d for d in data if d.get('Recommendation') == 'Avoid']),
    }

    return render(request, "admin/view_company_fundamental.html", {
        "data": data[:50],
        "sector": sector,
        "counts": counts
    })


import json
import pandas as pd
import yfinance as yf
from django.shortcuts import render


@login_required(login_url='/myapp/login_page/')
def show_graph_company(request, symbol):
    yf_symbol = symbol + ".NS" if not symbol.endswith(".NS") else symbol
    ticker = yf.Ticker(yf_symbol)
    hist = ticker.history(period="6mo")

    if hist.empty:
        return render(request, "admin/show_graph_company.html", {
            "symbol": symbol,
            "ohlc": json.dumps({}),
            "error": "No data available for this symbol"
        })

    hist.index = pd.to_datetime(hist.index)

    # Get additional info for statistics
    try:
        info = ticker.info
        current_price = info.get('currentPrice', hist['Close'].iloc[-1])
    except:
        current_price = hist['Close'].iloc[-1]

    # Prepare OHLC data
    ohlc_data = {
        "dates": hist.index.strftime("%Y-%m-%d").tolist(),
        "open": hist["Open"].round(2).tolist(),
        "high": hist["High"].round(2).tolist(),
        "low": hist["Low"].round(2).tolist(),
        "close": hist["Close"].round(2).tolist(),
        "volume": hist["Volume"].astype(int).tolist(),
        "current_price": float(current_price),
        "six_month_high": float(hist["High"].max()),
        "six_month_low": float(hist["Low"].min()),
        "avg_volume_30d": int(hist["Volume"].tail(30).mean())
    }

    return render(request, "admin/show_graph_company.html", {
        "symbol": symbol,
        "ohlc": json.dumps(ohlc_data),
        "error": None
    })



############Expert Core############


@login_required(login_url='/myapp/login_page/')
def view_company_fundamental_expert(request):
    sector = request.GET.get("sector", "NIFTY AUTO")
    rec_filter = request.GET.get("rec", "")
    data = build_analysis_table(sector)
    data = sorted(data, key=lambda x: x.get("Score", 0), reverse=True)

    # Calculate recommendations
    for item in data:
        score = item.get("Score", 0)
        if score >= 80:
            item["Recommendation"] = "Strong Buy"
        elif score >= 60:
            item["Recommendation"] = "Buy"
        elif score >= 40:
            item["Recommendation"] = "Hold"
        else:
            item["Recommendation"] = "Avoid"

    # Apply filter if selected
    if rec_filter:
        data = [d for d in data if d.get("Recommendation") == rec_filter]

    # Calculate counts for display
    counts = {
        'strong_buy': len([d for d in data if d.get('Recommendation') == 'Strong Buy']),
        'buy': len([d for d in data if d.get('Recommendation') == 'Buy']),
        'hold': len([d for d in data if d.get('Recommendation') == 'Hold']),
        'avoid': len([d for d in data if d.get('Recommendation') == 'Avoid']),
    }

    return render(request, "expert/view_company_fundamental.html", {
        "data": data[:50],
        "sector": sector,
        "counts": counts
    })


import json
import pandas as pd
import yfinance as yf
from django.shortcuts import render


@login_required(login_url='/myapp/login_page/')
def show_graph_company_expert(request, symbol):
    yf_symbol = symbol + ".NS" if not symbol.endswith(".NS") else symbol
    ticker = yf.Ticker(yf_symbol)
    hist = ticker.history(period="6mo")

    if hist.empty:
        return render(request, "expert/show_graph_company.html", {
            "symbol": symbol,
            "ohlc": json.dumps({}),
            "error": "No data available for this symbol"
        })

    hist.index = pd.to_datetime(hist.index)

    # Get additional info for statistics
    try:
        info = ticker.info
        current_price = info.get('currentPrice', hist['Close'].iloc[-1])
    except:
        current_price = hist['Close'].iloc[-1]

    # Prepare OHLC data
    ohlc_data = {
        "dates": hist.index.strftime("%Y-%m-%d").tolist(),
        "open": hist["Open"].round(2).tolist(),
        "high": hist["High"].round(2).tolist(),
        "low": hist["Low"].round(2).tolist(),
        "close": hist["Close"].round(2).tolist(),
        "volume": hist["Volume"].astype(int).tolist(),
        "current_price": float(current_price),
        "six_month_high": float(hist["High"].max()),
        "six_month_low": float(hist["Low"].min()),
        "avg_volume_30d": int(hist["Volume"].tail(30).mean())
    }

    return render(request, "expert/show_graph_company.html", {
        "symbol": symbol,
        "ohlc": json.dumps(ohlc_data),
        "error": None
    })


#####Forex Prediction##########


HTF_INTERVAL = "4h"
LTF_INTERVAL = "5m"
SYMBOLS = ["EURUSD=X", "GBPUSD=X", "USDJPY=X", "AUDUSD=X", "GC=F"]

def now_utc():
    return datetime.now(timezone.utc).strftime("%H:%M:%S")

def find_pivots(df, left=3, right=2):
    pivots = []
    if len(df) < (left + right + 1):
        return pivots
    for i in range(left, len(df) - right):
        high = df["High"].iloc[i]
        low = df["Low"].iloc[i]
        if all(high > df["High"].iloc[i - j] for j in range(1, left + 1)) and \
           all(high > df["High"].iloc[i + j] for j in range(1, right + 1)):
            pivots.append((i, float(high), "high"))
        if all(low < df["Low"].iloc[i - j] for j in range(1, left + 1)) and \
           all(low < df["Low"].iloc[i + j] for j in range(1, right + 1)):
            pivots.append((i, float(low), "low"))
    return pivots

def determine_structure(pivots):
    highs = [p[1] for p in pivots if p[2] == "high"]
    lows = [p[1] for p in pivots if p[2] == "low"]
    if len(highs) >= 2 and len(lows) >= 2:
        if highs[-1] > highs[-2] and lows[-1] > lows[-2]:
            return "uptrend"
        if highs[-1] < highs[-2] and lows[-1] < lows[-2]:
            return "downtrend"
    return "range"

def detect_choch_on_df(df, left=3, right=2):
    if len(df) < (left + right + 3):
        return None
    pivots = find_pivots(df, left=left, right=right)
    swing_highs = [p for p in pivots if p[2] == "high"]
    swing_lows = [p for p in pivots if p[2] == "low"]
    if not swing_highs or not swing_lows:
        return None
    trend = determine_structure(pivots)
    last_close = float(df["Close"].iloc[-1])
    last_high = swing_highs[-1][1]
    last_low = swing_lows[-1][1]
    if trend == "downtrend" and last_close > last_high:
        return {"type": "bullish_choch", "broken": float(last_high)}
    if trend == "uptrend" and last_close < last_low:
        return {"type": "bearish_choch", "broken": float(last_low)}
    return None

def detect_fvgs(df):
    fvgs = []
    for i in range(2, len(df)):
        c1 = df.iloc[i - 2]
        c3 = df.iloc[i]
        if float(c3["Low"]) > float(c1["High"]):
            fvgs.append({
                "type": "bullish",
                "gap_low": float(c1["High"]),
                "gap_high": float(c3["Low"]),
                "created_index": df.index[i]
            })
        if float(c3["High"]) < float(c1["Low"]):
            fvgs.append({
                "type": "bearish",
                "gap_low": float(c3["High"]),
                "gap_high": float(c1["Low"]),
                "created_index": df.index[i]
            })
    return fvgs

def detect_active_htf_fvgs(htf_df, ltf_df):
    active = []
    for f in detect_fvgs(htf_df):
        created = pd.to_datetime(f["created_index"])
        ltf_after = ltf_df[ltf_df.index >= created]
        if ltf_after.empty:
            active.append(f)
            continue
        filled = ((ltf_after["Close"] >= f["gap_low"]) & (ltf_after["Close"] <= f["gap_high"])).any()
        if not filled:
            active.append(f)
    return active

def detect_ltf_fvgs_inside_htf(htf_fvg, ltf_df):
    inside = []
    for f in detect_fvgs(ltf_df):
        if not (f["gap_high"] < htf_fvg["gap_low"] or f["gap_low"] > htf_fvg["gap_high"]):
            inside.append(f)
    return inside

def make_chart_base64(ltf_df, htf_fvg, ltf_fvg, choch, symbol):
    plot_df = ltf_df.tail(240)
    ap = [
        mpf.make_addplot([htf_fvg["gap_low"]] * len(plot_df), color='orange', alpha=0.3),
        mpf.make_addplot([htf_fvg["gap_high"]] * len(plot_df), color='orange', alpha=0.3),
    ]
    if ltf_fvg:
        ap += [
            mpf.make_addplot([ltf_fvg["gap_low"]] * len(plot_df), color='deepskyblue', alpha=0.3),
            mpf.make_addplot([ltf_fvg["gap_high"]] * len(plot_df), color='deepskyblue', alpha=0.3),
        ]
    if choch:
        color = 'lime' if choch["type"] == "bullish_choch" else 'red'
        ap.append(mpf.make_addplot([choch["broken"]] * len(plot_df), color=color, width=2, linestyle='--'))

    fig, _ = mpf.plot(
        plot_df, type='candle', style='charles', addplot=ap,
        title=f"{symbol} → {choch['type'].replace('_', ' ').title()}",
        returnfig=True, figsize=(11, 6), tight_layout=True
    )
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=110, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return f"data:image/png;base64,{base64.b64encode(buf.read()).decode()}"

def run_scanner():
    alerts = []
    seen = set()
    current_prices = {}

    for symbol in SYMBOLS:
        try:
            htf_df = yf.download(symbol, period="60d", interval=HTF_INTERVAL, progress=False, auto_adjust=False)
            ltf_df = yf.download(symbol, period="7d", interval=LTF_INTERVAL, progress=False, auto_adjust=False)

            if htf_df.empty or ltf_df.empty:
                continue

            # Fix multi-level columns
            if isinstance(htf_df.columns, pd.MultiIndex):
                htf_df.columns = htf_df.columns.get_level_values(0)
            if isinstance(ltf_df.columns, pd.MultiIndex):
                ltf_df.columns = ltf_df.columns.get_level_values(0)

            htf_df = htf_df[["Open", "High", "Low", "Close"]].dropna()
            ltf_df = ltf_df[["Open", "High", "Low", "Close"]].dropna()

            if len(htf_df) < 10 or len(ltf_df) < 20:
                continue

            current_price = float(ltf_df["Close"].iloc[-1])
            current_prices[symbol] = round(current_price, 5)

            for htf in detect_active_htf_fvgs(htf_df, ltf_df):
                for ltf_fvg in detect_ltf_fvgs_inside_htf(htf, ltf_df):
                    subset = ltf_df.tail(200).copy()
                    choch = detect_choch_on_df(subset)
                    if not choch:
                        continue
                    broken = choch["broken"]
                    if ltf_fvg["gap_low"] <= broken <= ltf_fvg["gap_high"]:
                        key = (symbol, htf["gap_low"], ltf_fvg["gap_low"], broken)
                        if key in seen:
                            continue
                        seen.add(key)

                        chart = make_chart_base64(ltf_df, htf, ltf_fvg, choch, symbol)

                        alerts.append({
                            "symbol": symbol,
                            "time": now_utc(),
                            "type": choch["type"].replace("_", " ").title(),
                            "price": round(current_price, 5),
                            "level": round(broken, 5),
                            "htf_type": htf["type"].title(),
                            "htf_low": round(htf["gap_low"], 5),
                            "htf_high": round(htf["gap_high"], 5),
                            "ltf_type": ltf_fvg["type"].title(),
                            "ltf_low": round(ltf_fvg["gap_low"], 5),
                            "ltf_high": round(ltf_fvg["gap_high"], 5),
                            "chart": chart
                        })
                        print(alerts)

        except Exception as e:
            print(f"Error {symbol}: {e}")
            continue

    return alerts, current_prices

@never_cache
def dashboard_view(request):
    alerts, prices = run_scanner()
    return render(request, "expert/forex_prediction.html", {
        "alerts": alerts,
        "prices": prices
    })
def alerts_api(request):
    return JsonResponse({"alerts": run_scanner()}, safe=False)



#########user function###########

def loginapp(request):
    username = request.POST['username']
    password = request.POST['password']
    user = authenticate(request, username=username, password=password)
    if user is not None:
        if user.groups.filter(name="user").exists():
            return JsonResponse({'status': 'success','lid':user.id})
        else:
            return JsonResponse({'status': 'error','message': 'Invalid user'})
    else:
        return JsonResponse({'status': 'error','message': 'Invalid username or password'})



def registerapp(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        name = request.POST['name']
        email = request.POST['email']
        phone = request.POST['phone']
        age = request.POST['age']
        photo = request.FILES['photo']
        place = request.POST['place']
        nationality = request.POST['nationality']
        if User.objects.filter(username=username).exists():
            return JsonResponse({'status': 'error','message': 'User already exists'})
        else:
            user=User.objects.create_user(username=username,password=password)
            user.groups.add(Group.objects.get(name='user'))
            user.save()
            userprofile=Investers()
            userprofile.name = name
            userprofile.email = email
            userprofile.phone = phone
            userprofile.age = age
            userprofile.photo = photo
            userprofile.place = place
            userprofile.nationality = nationality
            userprofile.LOGIN = user
            userprofile.save()
            return JsonResponse({'status': 'success','lid':user.id})




def send_data_request_expert(request):
    expert = Expert.objects.filter(status='accepted')
    ls = []
    for i in expert:
        ls.append(
            {
                'id':i.id,
                'name':i.name,
                'specilization':i.specilization,
                'photo':str(i.photo),
                'phone':i.phone,
                'email':i.email,
            }
        )
    return JsonResponse({'expert': ls})


def request_expert_user(request):
    if request.method == 'POST':
        expert_id = request.POST['expert_id']
        expert = Expert.objects.get(id=expert_id)
        user = Investers.objects.get(LOGIN_id=request.POST['lid'])
        user_request = User_request()
        user_request.Expert = expert
        user_request.Investers = user
        user_request.status = 'pending'
        user_request.occupation = request.POST['occupation']
        user_request.income = request.POST['income']
        user_request.amount = request.POST['amount']
        user_request.save()
        return JsonResponse({'status': 'success'})



def get_live_price_from_company(company_name):

    try:
        symbol = company_name.replace(" ", "").upper() + ".NS"
        df = yf.Ticker(symbol).history(period="1d")
        if df is not None and not df.empty:
            return round(df["Close"].iloc[-1], 2)
    except Exception:
        pass
    return 0

def get_user_portfolios(request):
    investor_login_id = request.POST['lid']

    portfolios = UserPortfolio.objects.filter(
        Investers__LOGIN_id=investor_login_id
    )

    response = []

    for port in portfolios:
        current_price = get_live_price_from_company(port.company)

        qty = float(port.number_of_stocks)
        buy_price = float(port.price_per_stock_when_bought)

        invested_value = round(qty * buy_price, 2)
        current_value = round(qty * current_price, 2)
        profit_loss = round(current_value - invested_value, 2)

        response.append({
            "Expert": port.Expert.name,
            "company": port.company,
            "current_price": current_price,
            "profit_loss": profit_loss,
        })

    return JsonResponse({"portfolios": response})


def view_tip_users(request):
    expert_id = Assgin_expert.objects.get(Investers__LOGIN_id=request.POST['lid']).Expert_id
    tipss =  Tips.objects.filter(Expert_id=expert_id)
    tips = []
    for tip in tipss:
        tips.append({
            "id": tip.id,
            "Expert": tip.Expert.name,
            "company": tip.company,
            "sector": tip.sector,
            "recommendation": tip.recommendation,
            "tips": tip.tips,
            "description": tip.description,
        })
    return JsonResponse({"tips": tips})


def chat_with_expert(request):
    expert_id = Assgin_expert.objects.get(Investers__LOGIN_id=request.POST['lid']).Expert_id
    sender_id = request.POST['lid']
    receiver_id = Expert.objects.get(id=expert_id).LOGIN_id
    chat = Chat()
    chat.from_id_id = sender_id
    chat.to_id_id   = receiver_id
    chat.message = request.POST['message']
    chat.date = datetime.now()
    chat.save()
    return  JsonResponse({'status': 'success'})

def view_chat_user(request):
    expert_id = Assgin_expert.objects.get(Investers__LOGIN_id=request.POST['lid']).Expert_id
    sender_id = request.POST['lid']
    receiver_id = Expert.objects.get(id=expert_id).LOGIN_id
    chat = Chat.objects.filter(
        Q(from_id_id=sender_id, to_id_id=receiver_id) | Q(from_id_id=receiver_id, to_id_id=sender_id)
    )
    chats=[]
    for i in chat:
        chats.append({
            "id": i.id,
            "from_id": str(i.from_id_id),
            "to_id": str(i.to_id_id),
            "message": str(i.message),
            "date": str(i.date),
        })
        print(chats,'hgchgfhfg')
    return JsonResponse({'chat': chats,'expert_name':Expert.objects.get(id=expert_id).name})


def send_complaint_user(request):
    complaints = Complaints()
    complaints.Investers = Investers.objects.get(LOGIN_id=request.POST['lid'])
    complaints.conplaint = request.POST['complaint']
    complaints.replay = 'pending'
    complaints.date = datetime.today()
    complaints.save()
    return JsonResponse({'status':'success'})

def view_replies(request):
    complaints = Complaints.objects.filter(Investers = Investers.objects.get(LOGIN_id=request.POST['lid']))
    replies = []
    for i in complaints:
        replies.append({
            "id": i.id,
            "complaint": i.conplaint,
            "replay": i.replay,
            "date": i.date,
        })
    return JsonResponse({'replies': replies})



def logouts(request):
    logout(request)
    return redirect('/myapp/login_page/')


