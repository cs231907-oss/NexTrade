import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse, HttpResponse
from django.shortcuts import render, redirect
from web3 import HTTPProvider, Web3

from myapp.models import News, Videos, Notifications, Customer, Complaint, Feedback, favourite, Buy_stock, Sell_stock, \
    Wallet
from datetime import datetime
from django.contrib.auth.models import User,Group
import pandas as pd
import requests

# Create your views here.

#for login


def login_get(request):
    return render(request,'admins/login.html')

def login_post(request):
    uname=request.POST['uname'] #name of the admin to check
    pswd=request.POST['pswd']   #password of the admin to check
    log=authenticate(username=uname,password=pswd)  #authenticate
    if log is not None:
        login(request,log)
        if log.groups.filter(name='admin'):
            return redirect('/myapp/home_index/')
        else:
            messages.error(request,"Invalid username or password")
            return redirect('/myapp/login/')
    else:
        messages.error(request, "Invalid username or password")
        return redirect('/myapp/login/')

def changepswd(request):
    return render(request,'admins/changepswd.html/')
def changepswd_post(request):
    currentpswd=request.POST['cpswd']
    newpswd=request.POST['npswd']
    confirm_pswd=request.POST['confirmpswd']
    user=request.user
    if user.check_password(currentpswd):
        # messages.error(request,"Invalid Password.")
        # return redirect('/myapp/changepswd_get/')
        if newpswd==confirm_pswd:
            user.set_password(newpswd)
            user.save()
            messages.success(request,'Password changed successfully!')
            messages.info(request,'Please login again to continue!')
            return redirect('/myapp/login/')
        else:
            messages.error(request,"New password and Confirm password doesn't match")
            return redirect('/myapp/changepswd_get/')
    else:
        messages.error(request,"Incorrect Password")
        return redirect('/myapp/changepswd_get/')
def logout(request):
    return redirect('/myapp/login/')

def forgot_password(request):
    return render(request,'admins/forgotpassword.html')

def forgotpassword_post(request):

    email=request.POST['uname']

    if User.objects.filter(username=email).exists():

        import random
        new_pass = random.randint(10000000, 99999999)
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login("nexcoin1922@gmail.com", " kjav kgmf ugbx jkma")  # App Password
        to = email
        subject = "Test Email"
        body = "Your new password is " + str(new_pass)
        msg = f"Subject: {subject}\n\n{body}"
        server.sendmail("s@gmail.com", to, msg)  # Disconnect from the server
        server.quit()

        user = User.objects.get(username=email)
        user.set_password(new_pass)
        user.save()

        return redirect('/myapp/login/')
    else:
        messages.warning(request, 'email not  exists')
        return redirect('/myapp/forgot_password/')

def viewusers(request):
    data=Customer.objects.all()
    return render(request, 'admins/viewuser.html', {'data': data})

def block_user(request,id):
    Customer.objects.filter(id=id).update(status='blocked')
    return redirect('/myapp/view_users/')

def unblock_user(request,id):
    Customer.objects.filter(id=id).update(status='unblocked')
    return redirect('/myapp/view_users/')


#for adding video
def addvideo(request):
    return render(request,'admins/add_videos.html')

def addvideo_post(request):
    vt=request.POST['vtitle'] #title of the video
    vd=request.FILES['vid']   #file of video
    fs=FileSystemStorage()
    date=datetime.now().strftime("%Y%m%d-%H%M%S")+'.mp4'
    fs.save(date,vd)
    path=fs.url(date)
    v=Videos()
    v.title=vt
    v.video=path
    v.date=datetime.now().date()
    v.save()    #to save the data given
    messages.success(request, "Successfully Saved!")
    return redirect('/myapp/view_video/')
 #for edit video
def editvideo(request,id):
    ed=Videos.objects.get(id=id)
    return render(request,'admins/editvideo.html',{'data':ed})

def editvideo_post(request):
    title=request.POST['vtitle'] #title of the video to edit
    ed=request.POST['id']   #id of the video
    vi=Videos.objects.get(id=ed)    #video table objects( to acces videos in table)

    # to get the video file to edit
    if "vidget" in request.FILES:
        video = request.FILES['vidget']
        fs = FileSystemStorage()
        date = datetime.now().strftime("%Y%m%d-%H%M%S") + '.mp4'
        fs.save(date, video)
        path = fs.url(date)
        vi.video = path #path of the video
        vi.save()

    vi.title=title
    vi.date=datetime.now().today()
    vi.save()
    messages.success(request, "Successfully Edited!")
    return redirect('/myapp/view_video/')

#for view video
def viewvideo(request):
    data = Videos.objects.all() #to get data from table and view
    return render(request,'admins/viewvideos.html',{'data': data})

def deletevideo(request,id):
    Videos.objects.get(id=id).delete()  #to delete
    messages.error(request,"Successfully Deleted!")
    return redirect('/myapp/view_video/')
#for adding news
def addnews(request):
    return render(request,'admins/addnews.html')

def addnews_post(request):
    ntitle=request.POST['ntitle']   #name of the news
    descr=request.POST['description']   #description of the news
    n=News()
    n.title=ntitle
    n.description=descr
    n.date=datetime.now().today()
    n.save()
    messages.success(request,"Successfully Saved!")
    return redirect('/myapp/view_news/')

#for edit news
def editnews(request,id):
    en=News.objects.get(id=id)   #table of the news to get id
    return render(request,'admins/editnews.html',{'data':en})

def editnews_post(request):
    entitle=request.POST['entitle']     #name of the news to edit
    descr=request.POST['edescr']        #descripton of the news to edit
    d=request.POST['id']    #storing id
    ne=News.objects.get(id=d)   #matching id from the table
    ne.title=entitle
    ne.description=descr
    ne.date=datetime.now().today()
    ne.save()
    messages.success(request, "Successfully Edited!")
    return redirect('/myapp/view_news/')

def deletenews(request,id):
    News.objects.get(id=id).delete()    #to delete
    messages.error(request, "Successfully Deleted!")
    return redirect('/myapp/view_news/')

#for view news
def viewnews(request):
    data=News.objects.all() #to get data from table and view
    return render(request,'admins/viewnews.html',{'data':data})

#for adding video
def addnotify(request):
    return render(request,'admins/addnotifi.html')

def addnotify_post(request):
    anotify=request.POST['anotifi']
    noti=Notifications()
    noti.title=anotify
    noti.date=datetime.now().today()
    noti.save()
    messages.success(request,"Successfully Saved!")
    return redirect('/myapp/view_notify/')

#for edit notifications
def editnotify(request,id):
    efy = Notifications.objects.get(id=id)
    return render(request,'admins/editnotifi.html',{'data':efy}) #efy=edit notification, to get object from get

def editnotify_post(request):
    enotify=request.POST['enotifi']
    n=request.POST['id']
    notif=Notifications.objects.get(id=n)
    notif.title=enotify
    notif.date=datetime.now().today()
    notif.save()
    messages.success(request, "Successfully Edited!")
    return redirect('/myapp/view_notify/')

def deletenotify (request,id):
    Notifications.objects.get(id=id).delete()
    messages.error(request, "Successfully Deleted!")
    return redirect('/myapp/view_notify/')

#for view notifications
def viewnotify(request):
    data = Notifications.objects.all()  #to get data from table and view
    return render(request,'admins/viewnotifi.html',{'data':data})

#for view complaint
def viewcomplaint(request):
    data=Complaint.objects.all()
    return render(request,'admins/viewcomplaint.html',{'data':data})

#for send reply
def sendreply(request,id):
    return render(request,'admins/sendreply.html',{'id':id})

def sendreply_post(request):
    send=request.POST['reply']
    id=request.POST['id']
    data=Complaint.objects.get(id=id)
    data.reply=send
    data.status="Resolved"
    data.save()
    return redirect('/myapp/view_complaint/')

#for view feedback
def viewfeed(request):
    data=Feedback.objects.all()
    return render(request,'admins/viewfeedback.html',{'data':data})

def h_index(request):
    user=Customer.objects.all().count()
    complaint=Complaint.objects.filter(status='pending').count()
    activetrade_count = Buy_stock.objects.filter(date=datetime.today()).count()
    return render(request,'admins/homepage.html',{'data':user,'reports':complaint,'active_trade':activetrade_count})

#user methods
def user_login(request):
    uemail=request.POST['uname']
    upass=request.POST['upassword']

    log=authenticate(request,username=uemail, password=upass)
    if log is not None:
        login(request,log)
        if log.groups.filter(name='user'):
             if Customer.objects.filter(USER_id=log.id,status='unblocked'):

                return JsonResponse({'status':'ok','uid':log.id})
             else:
                 return JsonResponse({'status': 'no'})

        else:
            return JsonResponse({'status':'no'})
    else:
        return JsonResponse({'status':'no'})

def user_signup(request):
    name=request.POST['uname']
    email=request.POST['uemail']
    phone=request.POST['uphoneno']
    state=request.POST['ustate']
    district=request.POST['udistrict']
    pin = request.POST['upin']
    password = request.POST['upassword']
    cfpassword = request.POST['ucpassword']

    if cfpassword!=password:
        return JsonResponse({'status':'no'})

    a=User.objects.create_user(username=email,password=password)
    a.groups.add(Group.objects.get(name='user'))
    a.save()

#for saving photo
    photo_file=request.FILES.get('photo')
    if photo_file:
        fs=FileSystemStorage()
        ext = photo_file.name.split('.')[-1]
        date = datetime.now().strftime("%Y%m%d-%H%M%S") + '.' + ext
        file_name=fs.save(date,photo_file)
        path=fs.url(file_name)
    else:
        path=''

    obj=Customer()
    obj.name=name
    obj.email=email
    obj.phone=phone
    obj.state=state
    obj.district=district
    obj.pin=pin
    obj.photo=path
    obj.USER=a
    obj.status='unblocked'
    obj.save()

    return JsonResponse({'status':'ok'})

def user_changepassword(request):
    currentpswd = request.POST['cpswd']
    newpswd = request.POST['npswd']
    confirm_pswd = request.POST['cmpswd']
    uid = request.POST['uid']
    user = User.objects.get(id=uid)
    if user.check_password(currentpswd):
        if newpswd == confirm_pswd:
            user.set_password(newpswd)
            user.save()
            return JsonResponse({'status': 'ok'})
        else:
            return JsonResponse({'status': 'no'})
    else:

        return JsonResponse({'status': 'no'})


def user_editprofile(request):
    id=request.POST['uid']
    name=request.POST['uname']
    email=request.POST['uemail']
    phone=request.POST['uphoneno']
    district=request.POST['udistrict']
    state=request.POST['ustate']
    pin=request.POST['upin']
    obj=Customer.objects.get(USER=id)

    if 'photo' in request.FILES:
        photo=request.FILES['photo']
        fs=FileSystemStorage()
        date=datetime.now().strftime("%Y%m%d-%H%M%S")
        fs.save(date,photo)
        path=fs.url(date)
        obj.photo=path
        obj.save()
    obj.name = name
    obj.email = email
    obj.phone = phone
    obj.state = state
    obj.district = district
    obj.pin = pin
    obj.save()
    return JsonResponse({'status':'ok'})

def user_viewprofile(request):
    uid=request.POST['uid']
    usr=Customer.objects.get(USER_id=uid)

    return JsonResponse({
        'status':'ok',
        'name':usr.name,
        'email':usr.email,
        'phone':usr.phone,
        'photo':usr.photo,
        'district':usr.district,
        'state':usr.state,
        'pin': usr.pin,

    })

def user_viewvideos(request):
    obj=Videos.objects.all()
    data=[]
    for i in obj:
        data.append({
            'title': i.title,
            'date': i.date,
            'video':i.video,
        })
    return JsonResponse({'status':'ok','data':data})

def user_viewnews(request):
    obj=News.objects.all()
    data=[]
    for i in obj:
        data.append({
            'title':i.title,
            'description':i.description,
            'date':i.date,
        })
    return JsonResponse({'status':'ok','data':data})

def user_viewnotification(request):
    obj = Notifications.objects.all()
    data=[]
    for i in obj:
        data.append({
            'title':i.title,
            'date':i.date,
        })

    return JsonResponse({'status':'ok','data':data})

def user_sendfeedback(request):
    id=request.POST['uid']
    ufeedback=request.POST['feedback']
    obj=Feedback()
    obj.feedback=ufeedback
    obj.date=datetime.now().today()
    obj.CUSTOMER=Customer.objects.get(USER=id)
    obj.save()
    return JsonResponse({'status':'ok'})

def user_sendcompliant(request):
    id=request.POST['uid']
    ucomplaint=request.POST['complaint']
    obj=Complaint()
    obj.complaint=ucomplaint
    obj.date=datetime.now().today()
    obj.CUSTOMER=Customer.objects.get(USER=id)
    obj.status="Pending"
    obj.reply='Pending'
    obj.save()

    return JsonResponse({'status':'ok'})

def user_viewreply(request):
    id=request.POST['uid']
    obj = Complaint.objects.filter(CUSTOMER__USER_id=id)
    data=[]
    for i in obj:
        data.append({
            'id':i.id,
            'complaint':i.complaint,
            'date':i.date,
            'status': i.status,
            'reply': i.reply,

        })
    return JsonResponse({'status':'ok','data':data})

#stock related methods

def getallstock(request):
    lid=request.POST["uid"]
    import pandas as pd
    # Fetch most traded stocks from Yahoo Finance

    import pandas as pd
    import requests
    url_link = 'https://finance.yahoo.com/markets/stocks/most-active/'
    r = requests.get(url_link, headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'})

    print(r.text)

    most_traded_stocks = pd.read_html(r.text)



    # most_traded_stocks = pd.read_html('https://finance.yahoo.com/markets/stocks/most-active/')
    # most_traded_stocks = pd.read_html('https://finance.yahoo.com/markets/stocks/trending/')
    # most_traded_stocks = pd.read_html('https://finance.yahoo.com/most-active')
    most_traded_stocks = most_traded_stocks[0]  # Assuming the table is the first one on the page

    # Extract stock symbols
    stock_symbols = most_traded_stocks['Symbol'].tolist()

    # Print the list of stock symbols
    print(stock_symbols)

    s=[]



    for i in stock_symbols:

        import yfinance as yf

        try:
            ticker = yf.Ticker(i)
            price = ticker.fast_info["last_price"]
        except:
            price=0
        try:
            hist = ticker.history(period="2d")  # last 2 days
            prev_close = hist["Close"].iloc[-2]
        except:
            prev_close = 0

        d="no"

        if favourite.objects.filter(name=i,CUSTOMER__USER_id=lid).exists():
            d="yes"


        s.append({
            'name': i,
            'a': 'yes',
            'price': price,
            'prev_close': prev_close,
            'is_favorite':d
        })
    #6?
    #     if favstock.objects.filter(stockname=i, USER__LOGEIN_id=lid).exists():
    #        a="yes"
    #        s.append({'name':i,'a':a})
    #     else:
    #         a="no"
    #         s.append({'name':i,'a':a})
    return JsonResponse({'data':s,'status':'ok'})

def stock_detail(request):

    name=request.POST["name"]
    import  yfinance as yd

    cdate= datetime.now().strftime("%Y-%m-%d")
    # Fetch stock data for one stock (e.g., AAPL for Apple)
    stock_data = yd.download(name, start='2022-01-01', end=cdate, interval='1d')

    d=stock_data
    # print(d.values,"dddddddddddd")
    l=[]

    for i in d.values:

        print(i)

        l.append(
            {
                'date':i[0],
                'open':i[1],
                'high':i[2],
                'low':i[3],
                'close':i[4],
                'volume':i[4],

              }
        )
        # print(i[0],"dateeeeeeeeeeeeeee")

    return JsonResponse({'status':'ok','data': l})

def priceprediction(request):


    name=request.POST["name"]


    import yfinance as yf
    import pandas as pd
    from sklearn.ensemble import RandomForestRegressor
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import mean_squared_error

    # Fetch live stock market data for a specific stock (e.g., Apple - AAPL)

    cdate = datetime.now().strftime("%Y-%m-%d")
    stock_data = yf.download(name, start='2022-01-01', end=cdate, interval='1d')

    # Assuming 'Close' column contains the target variable (stock prices)
    X = stock_data[['Open', 'High', 'Low', 'Volume']]  # Features
    y = stock_data['Close']  # Target variable

    # Split the data into training and testing sets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Initialize the Random Forest Regressor
    rf_regressor = RandomForestRegressor(n_estimators=100, random_state=42)
    rf_regressor.fit(X_train, y_train)
    next_day_features = X_test.iloc[-1].values.reshape(1, -1)
    next_day_predictionrf = rf_regressor.predict(next_day_features)
    print("Predicted next day's stock price:", next_day_predictionrf[0])
    y_pred = rf_regressor.predict(X_test)
    mse_rf = mean_squared_error(y_test, y_pred)
    print("Mean Squared Error:", mse_rf)
    print(X)

    from  sklearn.linear_model import  LinearRegression
    rf_regressor = LinearRegression()
    rf_regressor.fit(X_train, y_train)
    next_day_features = X_test.iloc[-1].values.reshape(1, -1)
    next_day_predictionlf = rf_regressor.predict(next_day_features)
    print("Predicted next day's stock price:", next_day_predictionlf[0])
    y_pred = rf_regressor.predict(X_test)
    mse_lf = mean_squared_error(y_test, y_pred)
    print("Mean Squared Error:", mse_rf)
    print(X)
    print(next_day_predictionlf,'lfffffff')
    print(next_day_predictionrf,"rffffff")

    v=float(next_day_predictionrf[0])+float(next_day_predictionlf[0][0])
    avg=v/2


    return  JsonResponse(
        {
            'status':'ok',
            'rf':str(round(next_day_predictionrf[0])),
            'lr':str(round(next_day_predictionlf[0][0])),
            'avg':str(round(avg)),

        }
    )

def addfav_post(request):
    name=request.POST['name']
    lid=request.POST['lid']

    if favourite.objects.filter(CUSTOMER__USER_id=lid,name=name).exists():
        favourite.objects.filter(CUSTOMER__USER_id=lid,name=name).delete()
        return JsonResponse({'status':'ok'})
    else:
        f=favourite()
        f.name=name
        f.CUSTOMER=Customer.objects.get(USER_id=lid)
        f.save()
        return JsonResponse({'status':'ok'})

def viewFav(request):

        lid = request.POST.get('lid')
        if not lid:
            return JsonResponse({'status': 'error', 'message': 'Missing lid'}, status=400)

        # Fetch favorite stocks for this user
        fav_objects = favourite.objects.filter(CUSTOMER__USER_id=lid)
        fav_names = set(i.name for i in fav_objects)

        # Fetch live stock data from Yahoo Finance
        url_link = 'https://finance.yahoo.com/markets/stocks/most-active/'
        r = requests.get(url_link, headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })

        # Parse the HTML table
        most_traded_stocks = pd.read_html(r.text)[0]  # take first table
        stock_symbols = most_traded_stocks['Symbol'].tolist()

        # Build stock list with favorite comparison
        stock_list = []
        for i, symbol in enumerate(stock_symbols, start=1):
            fav_entry = next((f for f in fav_objects if f.name == symbol), None)

            import yfinance as yf
            try:

                ticker = yf.Ticker(str(symbol))
                price = ticker.fast_info["last_price"]
            except:
                price=0

            try:
                hist = ticker.history(period="2d")  # last 2 days
                prev_close = hist["Close"].iloc[-2]
            except:
                prev_close=0

            if fav_entry:
                stock_list.append({
                    'id': fav_entry.id if fav_entry else '0',  # actual DB ID if in favorites
                    'name': str(symbol),
                    'is_favorite': 'yes' if fav_entry else 'no',
                    'price':price,
                    'prev_close':prev_close,

                })



        return JsonResponse({'status': 'ok', 'data': stock_list})

def remove_fav_stock(request):
    id=request.POST['id']
    favourite.objects.get(id=id).delete()
    return JsonResponse({'status': 'ok'})

def pay(acc1,prvkey,amount):
    blockchain_address = "HTTP://127.0.0.1:7545"
    web3 = Web3(HTTPProvider(blockchain_address))

    if web3.is_connected():

        acc2 = web3.eth.accounts[2]
        nonce = web3.eth.get_transaction_count(acc1)
        abcd = web3.eth.get_balance(acc1)
        abcd = web3.from_wei(abcd, 'ether')
        tx = {
            'nonce': nonce,
            'to': acc2,
            'value': web3.to_wei(amount, 'ether'),
            'gas': 200000,
            'gasPrice': web3.to_wei('50', 'gwei')
        }
        signedtx = web3.eth.account.sign_transaction(tx, prvkey)
        hashx = web3.eth._send_raw_transaction(signedtx.raw_transaction)

def pay1(acc1,amount):
    blockchain_address = "HTTP://127.0.0.1:7545"
    web3 = Web3(HTTPProvider(blockchain_address))
    acc3_key="0x478b8397c0f70e41e6c8702004e9d8b584d313eb0abe7868576d48fddf71443c"
    acc3_accno= "0xc03B358D1F12e191c7A79faC33BDF5ef68470479"

    if web3.is_connected():

        acc2 = web3.eth.accounts[2]
        nonce = web3.eth.get_transaction_count(acc3_accno)
        abcd = web3.eth.get_balance(acc1)
        abcd = web3.from_wei(abcd, 'ether')
        tx = {
            'nonce': nonce,
            'to': acc1,
            'value': web3.to_wei(amount, 'ether'),
            'gas': 200000,
            'gasPrice': web3.to_wei('50', 'gwei')
        }
        signedtx = web3.eth.account.sign_transaction(tx, acc3_key)
        hashx = web3.eth._send_raw_transaction(signedtx.raw_transaction)

# def pay1(acc, amount):
#     print(f"[TEST MODE] Would send {amount} to {acc}")
#     return True

def buy_stock(request):
    id = request.POST['uid']
    lid = request.POST['lid']
    qty = request.POST['qty']
    account=request.POST['acc']
    prvkey=request.POST['pkey']

    fv=favourite.objects.get(id=id)
    stockname= fv.name
    import yfinance as yf

    ticker = yf.Ticker(stockname)
    price = ticker.fast_info["last_price"]

    amount= float(price)* float(qty)



    from web3 import Web3, HTTPProvider

    blockchain_address = 'HTTP://127.0.0.1:7545'
    web3 = Web3(HTTPProvider(blockchain_address))
    web3.eth.defaultAccount = web3.eth.accounts[0]


    w=Wallet.objects.get(CUSTOMER__USER_id=lid)
    # Check if user has enough balance
    if w.amount < int(amount):
        return JsonResponse({'status': 'error', 'message': 'Insufficient wallet balance'})
    w.amount = w.amount - int(amount)  # Subtract from the wallet
    w.save()

    pay(account,prvkey,amount)
    b = Buy_stock()
    b.FAVOURITE = favourite.objects.get(id=id)
    b.stock = qty
    b.date=datetime.now().date()
    b.purchase_price=round(price,2)
    b.total_amount=round(amount,2)
    b.save()
    return JsonResponse({'status': 'ok'})

def view_buy_stock(request):
    id = request.POST['uid']
    obj = Buy_stock.objects.filter(FAVOURITE_id=id)
    data = []
    for i in obj:

        import yfinance as yf
        try:

            ticker = yf.Ticker(str(i.FAVOURITE.name))
            price = ticker.fast_info["last_price"]
        except:
            price = 0

        try:
            hist = ticker.history(period="2d")  # last 2 days
            prev_close = hist["Close"].iloc[-2]
        except:
            prev_close = 0

        prevdayamount = float(prev_close) * float(i.stock)
        todayamount = float(price) * float(i.stock)

        daily_pnl = todayamount - prevdayamount  # Positive = profit, Negative = loss

        # Calculate actual profit/loss from purchase
        actual_profit_loss = (float(price) - i.purchase_price) * float(i.stock)

        data.append({
            'id': i.id,
            'Name': i.FAVOURITE.name,
            'Stock': i.stock,
            'daily_pnl': round(daily_pnl, 2),  # Combined field
            'purchase_price': i.purchase_price,
            'total_amount': i.total_amount,
            'current_price': round(float(price), 2),
            'current_value': round(todayamount, 2),
            'actual_pnl': round(actual_profit_loss, 2),
        })
    return JsonResponse({'status': 'ok', 'data': data})

def sell_stock(request):
    id = request.POST['uid']
    lid = request.POST['lid']
    quantity = request.POST['quantity']
    account=request.POST['acc']

    #to check if the stock exist or the quantity exceed the stock quantity.
    if int(quantity) <= 0:
        return JsonResponse({'status': 'error', 'message': 'Invalid quantity'})

    stockname = Buy_stock.objects.get(id=id).FAVOURITE.name

    b = Buy_stock.objects.get(id=id)

    if int(b.stock) <= 0:
        return JsonResponse({'status': 'error', 'message': 'No stock available'})

    if int(b.stock) < int(quantity):
        return JsonResponse({'status': 'error', 'message': f'Insufficient stock. Available: {b.stock}'})

    import yfinance as yf

    ticker = yf.Ticker(stockname)
    price = ticker.fast_info["last_price"]

    amount = float(price) * float(quantity)


    from web3 import Web3, HTTPProvider

    blockchain_address = 'HTTP://127.0.0.1:7545'
    web3 = Web3(HTTPProvider(blockchain_address))
    web3.eth.defaultAccount = web3.eth.accounts[0]

    w = Wallet.objects.get(CUSTOMER__USER_id=lid)
    w.amount = w.amount + int(amount)
    w.save()

    b=Buy_stock.objects.get(id=id)
    b.stock= int(b.stock)-int(quantity)
    b.save()

    pay1(account,amount)
    s = Sell_stock()
    s.BUYSTOCK = Buy_stock.objects.get(id=id)
    s. stock_quantity = quantity
    s.date=datetime.now().date()
    s.sell_price=round(price,2)
    s.total_amount=round(amount,2)
    s.save()
    return JsonResponse({'status': 'ok'})

def view_sell_stock(request):
    id = request.POST['uid']
    sid = request.POST['sid']
    obj = Sell_stock.objects.filter(BUYSTOCK__FAVOURITE__CUSTOMER__USER_id=id, BUYSTOCK__FAVOURITE__name=sid)
    data = []
    for i in obj:

        import yfinance as yf
        try:
            ticker = yf.Ticker(str(i.BUYSTOCK.FAVOURITE.name))
            price = ticker.fast_info["last_price"]
        except:
            price = 0

        try:
            hist = ticker.history(period="2d")  # last 2 days
            prev_close = hist["Close"].iloc[-2]
        except:
            prev_close = 0

        prevdayamount = float(prev_close) * float(i.stock_quantity)
        todayamount = float(price) * float(i.stock_quantity)

        daily_pnl = todayamount - prevdayamount

        # Calculate actual profit/loss from purchase vs sale
        actual_profit_loss = (i.sell_price - i.BUYSTOCK.purchase_price) * float(i.stock_quantity)

        data.append({
            'id': i.id,
            'Name': i.BUYSTOCK.FAVOURITE.name,
            'Stock': i.stock_quantity,
            'daily_pnl': round(daily_pnl, 2),  # Combined field
            'sell_price': i.sell_price,  # Price when sold
            'total_amount': i.total_amount,  # Amount received from sale
            'actual_pnl': round(actual_profit_loss, 2),
        })
    return JsonResponse({'status': 'ok', 'data': data})

def view_sell_fastock(request):
    id = request.POST['uid']
    sid = request.POST['sid']
    obj = Sell_stock.objects.filter(BUYSTOCK__FAVOURITE__CUSTOMER__USER_id=id, BUYSTOCK__FAVOURITE_id=sid)
    data = []
    for i in obj:

        import yfinance as yf
        try:
            ticker = yf.Ticker(str(i.BUYSTOCK.FAVOURITE.name))
            price = ticker.fast_info["last_price"]
        except:
            price = 0

        try:
            hist = ticker.history(period="2d")  # last 2 days
            prev_close = hist["Close"].iloc[-2]
        except:
            prev_close = 0

        prevdayamount = float(prev_close) * float(i.stock_quantity)
        todayamount = float(price) * float(i.stock_quantity)

        daily_pnl = todayamount - prevdayamount

        # Calculate actual profit/loss from purchase vs sale
        actual_profit_loss = (i.sell_price - i.BUYSTOCK.purchase_price) * float(i.stock_quantity)

        data.append({
            'id': i.id,
            'Name': i.BUYSTOCK.FAVOURITE.name,
            'Stock': i.stock_quantity,
            'daily_pnl': round(daily_pnl, 2),
            'sell_price': round(i.sell_price, 2),
            'total_amount': i.total_amount,
            'actual_pnl': round(actual_profit_loss, 2),
        })
    return JsonResponse({'status': 'ok', 'data': data})

def buy_high_graph(request):
    name = request.POST["name"]
    import yfinance as yd

    cdate = datetime.now().strftime("%Y-%m-%d")
    # Fetch stock data for one stock (e.g., AAPL for Apple)
    stock_data = yd.download(name, start='2022-01-01', end=cdate, interval='1d')

    d = stock_data
    l = []

    for i in d.values:
        print(i)

        l.append(
            {
                'high': i[2],
            }
        )

    return JsonResponse({'status': 'ok','data': l})

def Recharge_coin(request):
    lid=request.POST['lid']
    acc_address=request.POST['acc']
    pv_key=request.POST['pv_key']
    amnt=request.POST['amnt']

    if Wallet.objects.filter(CUSTOMER=Customer.objects.get(USER_id=lid)).exists():

        pay(acc_address,pv_key,amnt)

        print("ok1")
        a=Wallet.objects.get(CUSTOMER=Customer.objects.get(USER_id=lid))
        a.amount=a.amount+int(amnt)
        a.save()
    else:

        print("ok2")

        obj=Wallet()
        obj.amount=amnt
        obj.CUSTOMER=Customer.objects.get(USER_id=lid)
        obj.save()

    return JsonResponse({'status': 'ok'})

def Balance_coin(request):
    lid = request.POST['lid']
    w= Wallet.objects.filter(CUSTOMER__USER_id=lid)
    if w.exists():
        return JsonResponse(
            {
                'status':'ok',
                'amount':w[0].amount
            }
        )
    else:
        return JsonResponse({'status': 'no'})

def android_forget_password_post(request):
    import random
    email = request.POST.get('email')
    if not email:
        return JsonResponse({'status': 'error', 'message': 'Email is required'})

    try:
        user = User.objects.get(username=email)
        print(email)

        # Generate new password
        new_pass = str(random.randint(10000000, 99999999))
        user.password = make_password(new_pass)
        user.save()

        # Email configuration
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = "nexcoin1922@gmail.com"
        app_password = "kjav kgmf ugbx jkma"

        subject = "Your New Password"
        body = f"Your new password is: {new_pass}"
        message = MIMEMultipart()
        message["From"] = sender_email
        message["To"] = email
        message["Subject"] = subject
        message.attach(MIMEText(body, "plain"))

        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(message)
        server.quit()

        return JsonResponse({'status': 'ok', 'message': 'Password sent to your email'})

    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Email not found'})

    except Exception as e:
        return JsonResponse({'status': 'error', 'message': f'Email send error: {str(e)}'})
