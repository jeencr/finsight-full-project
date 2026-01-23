from datetime import datetime
from django.contrib import messages
from django.contrib.auth import authenticate, login
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

def admin_home(request):
    return render(request,'admin/adminhome.html')

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

def view_investers(request):
    investers=Investers.objects.all()
    return render(request,'admin/viewinvesters.html',{"investers":investers})


def view_feedback(request):
    viewfeedback=Feed_back.objects.all()
    return render(request,'admin/viewfeedback.html',{"viewfeedback":viewfeedback})


def view_complaints(request):
    viewcomplaints=Complaints.objects.all()
    return render(request,'admin/complaint.html',{"viewcomplaints":viewcomplaints})


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




def view_notification(request):
    viewnotification=Notification.objects.all()
    return render(request,'admin/viewnotification.html',{"viewnotification":viewnotification})

def delete_notification(request,id):
    deletenotification=Notification.objects.get(id=id)
    deletenotification.delete()
    return redirect('/myapp/view_notification/')

def expert_home(request):
    return render(request,'expert/expertheader.html')


def viewprofile(request):
    expertid=request.user.id
    viewprofile=Expert.objects.get(LOGIN_id=expertid)
    return render(request,'expert/manageprofile.html',{"viewprofile":viewprofile})


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

def assigned_users(request):
    id=request.user.id
    expertid = Expert.objects.get(LOGIN_id=id)
    assignuser = Assgin_expert.objects.filter(Expert=expertid)
    return render(request, 'expert/assignuser.html', {"assign_user": assignuser})

def view_request_admin(request):
    reqs = User_request.objects.filter(status='pending')
    return render(request, 'admin/view_request.html', {"reqs": reqs})



# def managetips(request):
#     investers=Investers.objects.all()
#     return render(request,'admin/viewinvesters.html',{"investers":investers})



#####core#####
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
