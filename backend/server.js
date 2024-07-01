const express = require('express');
const app = express();
var cors = require ("cors");
const multer=require ("multer");
const finnhub = require('finnhub');
app.use(cors());
var symbolAndName = {}
const uri = "mongodb+srv://admin:csci571hw3@cluster0.hdxgdrb.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const api_key = finnhub.ApiClient.instance.authentications['api_key'];
api_key.apiKey = "cn2n2o1r01qt9t7ut4q0cn2n2o1r01qt9t7ut4qg";
const finnhubClient = new finnhub.DefaultApi()

const { MongoClient } = require('mongodb');

const client = new MongoClient(uri);
var database;
var collection;

const currentDate = new Date();
const year = currentDate.getFullYear();
const month = String(currentDate.getMonth() + 1).padStart(2, '0');
const day = String(currentDate.getDate()).padStart(2, '0');
const formattedDateToday = `${year}-${month}-${day}`;

async function connectToMongoDB() {
    try {
        await client.connect();
        console.log('Connected to MongoDB server successfully');

        database = client.db('hw4');

        collection = database.collection('hw4'); 

        const query = {}; 
        documents = await collection.find(query).toArray();

        console.log('WatchlistTicker elements:', documents);

    } catch (error) {
        console.error('Error connecting to MongoDB:', error);
     }
    
}

connectToMongoDB();

var companyDetails;

app.listen(8080, () => {
    console.log("server started on port 8080");
});

app.get("/test", (req, res)=>{
    res.send(documents)
})

app.get('/autocomplete/:partialSymbol', async (req,res)=>{
    var partialSymbol = req.params.partialSymbol;
    var url = "https://finnhub.io/api/v1/search?q=" + partialSymbol + "&token=cn2n2o1r01qt9t7ut4q0cn2n2o1r01qt9t7ut4qg";
    response = await fetch(url);
    var autoCompSuggestions = await response.json();
    const resultSubset = autoCompSuggestions.result.map(item => [item.symbol, item.description]);
    const newJson = JSON.stringify(resultSubset, null, 2);
    const filteredData = resultSubset.filter(subArray => !subArray[0].includes('.'));
    res.send(filteredData);
    
})

app.get("/search/companyProfile/:ticker", (req,res)=>{
    var tickerName = req.params.ticker;
    finnhubClient.companyProfile2({'symbol': tickerName}, (error, data, response) => {
        
        symbolAndName[data['ticker']] = data['name'];
        res.send(data);
    });
})

app.get("/search/companyQuote/:ticker", async(req,res)=>{
    var tickerName = req.params.ticker;
    var tp = await quoteCall(tickerName);
    res.send(tp);
})

app.get("/search/peers/:ticker", async(req,res)=>{
    var tickerNam = req.params.ticker;
    var url = "https://finnhub.io/api/v1/stock/peers?symbol=" + tickerNam + "&token=cn2n2o1r01qt9t7ut4q0cn2n2o1r01qt9t7ut4qg";
    response = await fetch(url);
    var peers = await response.json();
    let filteredSymbols = peers.filter(symbol => !symbol.includes('.'));
    res.send(filteredSymbols);
})

app.get("/search/charts/hourly/:ticker/:from/:to", async(req,res)=>{
    var tickerNam = req.params.ticker;
    tickerNam = tickerNam.toUpperCase();
    var from = req.params.from;
    var to = req.params.to;
    var url = `https://api.polygon.io/v2/aggs/ticker/${tickerNam}/range/1/hour/${from}/${to}?adjusted=true&sort=asc&apiKey=YzLOupt6B9xcE91frptcCxsRG0QVEI3v`;
    response = await fetch(url);
    var chartHourlyInfo = await response.json();
    res.send(chartHourlyInfo);
})

app.get("/search/charts/daily/:ticker/:from/:to", async(req,res)=>{
    var tickerNam = req.params.ticker;
    tickerNam = tickerNam.toUpperCase();
    var from = req.params.from;
    var to = req.params.to;
    var url = `https://api.polygon.io/v2/aggs/ticker/${tickerNam}/range/1/day/${from}/${to}?adjusted=true&sort=asc&apiKey=YzLOupt6B9xcE91frptcCxsRG0QVEI3v`;
    response = await fetch(url);
    var chartDailyInfo = await response.json();

    var volumeDate = chartDailyInfo.results.map((obj) => {
        return [obj.t, obj.v];
      });

      var OHLCDate = chartDailyInfo.results.map((obj) => {
        return [obj.t, obj.o, obj.h, obj.l, obj.c];
      });
      var respJson = {}
      respJson["volumeDate"] = volumeDate
      respJson["OHLCDate"] = OHLCDate


    res.send(respJson);
})



app.get('/news/:ticker', (req,res)=>{
    var tickerName = req.params.ticker;
    
    const oneWeekBefore = new Date(currentDate);
    oneWeekBefore.setDate(currentDate.getDate() - 7);

    const yearBefore = oneWeekBefore.getFullYear();
    const monthBefore = String(oneWeekBefore.getMonth() + 1).padStart(2, '0');
    const dayBefore = String(oneWeekBefore.getDate()).padStart(2, '0');
    var formattedDateBefore = `${yearBefore}-${monthBefore}-${dayBefore}`;

    finnhubClient.companyNews(tickerName, formattedDateBefore, formattedDateToday, (error, data, response) => {
        
        var ctr=0;
        var finalNews = []
        var news = data
        if (JSON.stringify(news) != '{}'){
            for(let i=0; i<news.length; i++){
                if(ctr==20)  break;
                else{
                    var record = news[i]
                    if(record.url != "" && record.image != "" && record.headline != "" && record.datetime != ""){
                    finalNews.push(record);
                            ctr++;
                    }
                }
            }
            for (var i = 0; i < finalNews.length; i++) {
                var timestamp = finalNews[i].datetime;
                var currentDate = new Date();
                var newsDate = new Date(timestamp * 1000);
            
                var timeDifference = currentDate - newsDate;
                var hours = Math.floor(timeDifference / (1000 * 60 * 60));
                var minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));
            
                var timeString = "";
                if (hours > 0) {
                    timeString += hours + "hr, ";
                }
                if (minutes > 0) {
                    timeString += minutes + "min";
                }
                if (timeString === "") {
                    timeString = "Just now";
                }
            
                finalNews[i].dateString = timeString;
            }
            
        }
        
        res.send(finalNews);
    });
})


app.get('/insights/insiderSenti/:ticker' , (req,res)=>{
    var insiderSenti;
    var tickerName = req.params.ticker;
    finnhubClient.insiderSentiment(tickerName, '2022-01-01', formattedDateToday, (error, data, response) => {
        insiderSenti = data["data"];
        var tot = []; var pos = [] ; var neg = [];

        var temp = insiderSenti;
        temp.forEach(obj => {
        tot.push(obj.mspr);
        if (obj.mspr > 0) {
            pos.push(obj.mspr);
        } else if (obj.mspr < 0) {
            neg.push(obj.mspr);
        }
        });

        var sum = tot.reduce((acc, val) => acc + val, 0);
        var totalMSPR = sum ;
        sum = pos.reduce((acc, val) => acc + val, 0);
        var posMSPR = sum ;
        sum = neg.reduce((acc, val) => acc + val, 0);
        var negMSPR = sum ;

        var totch = [];
        var posch = [];
        var negch = [];

        temp.forEach(obj => {
            totch.push(obj.change);
            if (obj.mspr > 0) {
              posch.push(obj.change);
            } else if (obj.mspr < 0) {
              negch.push(obj.change);
            }
        });

        var sum = totch.reduce((acc, val) => acc + val, 0);
        var totalChng = sum ;
        sum = posch.reduce((acc, val) => acc + val, 0);
        var posChng = sum ;
        sum = negch.reduce((acc, val) => acc + val, 0);
        var negChng = sum ;

        var returnJSON = {};
        returnJSON["totalMSPR"] = totalMSPR;
        returnJSON["posMSPR"] = posMSPR;
        returnJSON["negMSPR"] = negMSPR;
        returnJSON["totalChng"] = totalChng;
        returnJSON["posChng"] = posChng;
        returnJSON["negChng"] = negChng;


        res.send(returnJSON);
    });
})

app.get('/insights/recomm/:ticker' , (req,res)=>{
    var tickerName = req.params.ticker;
    finnhubClient.recommendationTrends(tickerName, (error, data, response) => {
        res.send(data);
    });
})

app.get('/insights/earnings/:ticker' , (req,res)=>{
    var tickerName = req.params.ticker;
    finnhubClient.companyEarnings(tickerName, {'limit': 20}, (error, data, response) => {
        res.send(data);
    });
})

app.get('/watchlist',async (req,res)=>{
    // await connectToMongoDB();

    documents = await collection.find({}).toArray();
    watchlistArray = documents[0]['watchlist'].split(',')
    var watchlistDetailed = [];
    if (watchlistArray[0]==''){
        res.send([]);
    }
    // else{
    //     for(var i of watchlistArray){
    //         var tp = await quoteCall(i);
    //         watchlistDetailed[i] = tp;
    //         console.log(watchlistDetailed[i]);
    //         tick = i.toUpperCase();
    //         watchlistDetailed[i]['name'] = symbolAndName[tick];
    //         watchlistDetailed[i]['symbol'] = tick;
    //     }
    //     console.log("watchlist not empty done");
    //     res.send(watchlistDetailed);
    // }
    else{
        for(var i of watchlistArray){
            var tp = await quoteCall(i);
            // tp.ticker = i
            // watchlistDetailed[i] = tp;
            // console.log(tp);
            tick = i.toUpperCase();
            tp.ticker = tick
            tp.name = symbolAndName[tick]
            watchlistDetailed.push(tp)
            // watchlistDetailed[i]['name'] = symbolAndName[tick];
            // watchlistDetailed[i]['symbol'] = tick;
        }
        // console.log(watchlistDetailed)
        res.send(watchlistDetailed);
    }
})

app.get('/watchlistAsArray',async (req,res)=>{
    documents = await collection.find({}).toArray();
    var watchlistAsArray = documents[0]['watchlist'].split(',');
    res.send(watchlistAsArray);
})


app.get('/watchlist/add/:ticker', async(req,res)=>{
    var ticker = req.params.ticker;
    symbol = "," + ticker;
    documents = await collection.find({}).toArray();
    watchlistArray = documents[0]['watchlist'].split(',')
    if (watchlistArray[0]==''){
        symbol = ticker;
    }
    
    
    collection.updateMany(
        { watchlist: { $exists: true } }, 
        [
          {
            $set: {
              watchlist: { $concat: ["$watchlist", symbol] }
            }
          }
        ]
      );
    res.send("added"); 
})


app.get('/watchlist/remove/:ticker' , async(req, res)=>{
    var ticker = req.params.ticker;
    symbol = "," + ticker;
    documents = await collection.find({}).toArray();
    watchlistArray = documents[0]['watchlist'].split(',')

    if(watchlistArray.length==1){
        symbol = ticker;
    }
    else if(watchlistArray.indexOf(ticker)==0){
        symbol = ticker + ",";
    }

    collection.updateMany(
        { watchlist: { $exists: true } }, 
        [
          {
            $set: {
              watchlist: {
                $replaceOne: {
                  input: "$watchlist", 
                  find: symbol, 
                  replacement: ""
                }
              }
            }
          }
        ]
      );
    res.send("deleted");  
})


app.get('/isStockInWatchlist/:ticker',async (req,res)=>{
    var tick = req.params.ticker;
    tick = tick.toUpperCase()
    documents = await collection.find({}).toArray();
    var watchlistAsArray = documents[0]['watchlist'].split(',');
    var isInWatch
    if (watchlistAsArray.includes(tick)) {
        isInWatch = true;
    } else {
        isInWatch = false;
    }
    res.send(isInWatch);
})

app.get('/reorderWatchlist/:wlJsonStr', async(req,res)=>{
    var wlJsonStr = req.params.wlJsonStr;
    var wlJson = JSON.parse(wlJsonStr);
    
    let temp = "";
      
      wlJson.forEach((item, index) => {
          temp += item.ticker;
          if (index !== wlJson.length - 1) {
              temp += ",";
          }
      });
      

    collection.updateMany(
        { watchlist: { $exists: true } }, 
        { $set: { watchlist: temp } } 
    );
})


app.get('/reorderPortfolio/:wlJsonStr', async(req,res)=>{
    var portJsonStr = req.params.wlJsonStr;
    var portJson = JSON.parse(portJsonStr);
    
    let transformedData = portJson.map(item => ({
        ticker: item.ticker,
        name: item.name,
        qty: item.qty,
        avgCost: item.avgCost
    }));
    let newArray = [];

    transformedData.forEach(item => {
        newArray.push(JSON.stringify(item));
    });


    collection.updateMany(
        {}, // Match all documents
        { $set: { portfolio: newArray } }
    );
})



app.get("/fundsAvailable", async(req,res)=>{
    // await connectToMongoDB();

    documents = await collection.find({}).toArray();
    fundsAvailable = documents[0]['fundsAvailable'];
    // res.send(String(fundsAvailable));
    const formattedFundsAvailable = fundsAvailable.toFixed(2);

    res.send(String(formattedFundsAvailable));
})

app.get("/fundsAvailable/edit/:change", async(req,res)=>{
    var change = Number(req.params.change);
    documents = await collection.find({}).toArray();
    fundsRemaining = Number(documents[0]['fundsAvailable']);
    fundsRemaining = change;
    collection.updateMany(
        {}, 
        { $set: { fundsAvailable: fundsRemaining } } 
      );
    res.send("changed");
})

app.get("/getPortfolioValue", async (req, res) => {
    // await connectToMongoDB();

    documents = await collection.find({}).toArray();
    portfolioArray = await documents[0]['portfolio'];
    var portFinal = await portfolioArray.map(item => JSON.parse(item));

    var netWorth = 0;

    for (const item of portFinal) {
        let quote = await quoteCall(item.ticker);
        let currentPrice = await quote['c'];
        let value = await item.qty * currentPrice;
        netWorth += await value;
    }

    var PortfolioValue = netWorth;

    res.send(PortfolioValue.toString());
});



async function quoteCall(i){
    var apiURl = `https://finnhub.io/api/v1/quote?symbol=${i}&token=cn2n2o1r01qt9t7ut4q0cn2n2o1r01qt9t7ut4qg`
    response = await fetch(apiURl);
    var quote = await response.json();
    return quote;

}


app.get("/getPortfolio", async(req,res)=>{
    // await connectToMongoDB();

    documents = await collection.find({}).toArray();
    portfolioArray = documents[0]['portfolio'];
    var portFinal = portfolioArray.map(item => JSON.parse(item));

    for (const item of portFinal) {
        let response = await quoteCall(item.ticker);
        let currentPrice = response["c"];
        item.currentPrice = currentPrice
        item.total = currentPrice * item.qty
        item.change = item.total - (item.qty * item.avgCost)
        item.changePer = (item.change / (item.qty * item.avgCost))*100
    }

    res.send(portFinal);
})

app.get("/updatePortfolio/:updates", async(req,res)=>{
    
    var updates = req.params.updates;
    var updatedPortElement = JSON.parse(updates);
    let tickerToUpdate = updatedPortElement.ticker;
    let newQty = updatedPortElement.qty;
    
    let newAvgCost = updatedPortElement.avgCost; 
    let name = updatedPortElement.name;
    console.log(tickerToUpdate, updatedPortElement.ticker ,updatedPortElement);
    let documents = await collection.find({}).toArray();
    let portfolioArray = documents[0]['portfolio'];
    let portFinal = portfolioArray.map(item => JSON.parse(item));

    let index = portFinal.findIndex(item => item.ticker === tickerToUpdate);
    console.log("index:", index)
    if (index !== -1) {
        portFinal[index].qty = newQty;
        portFinal[index].avgCost = newAvgCost;
    } else {
        portFinal.push({ ticker: tickerToUpdate, name : name, qty: newQty, avgCost: newAvgCost });
    }

    let updatedPortfolioArray = portFinal.map(item => JSON.stringify(item));

    let docId = documents[0]['_id'];

    await collection.updateOne(
        { _id: docId },
        { $set: { portfolio: updatedPortfolioArray } }
    );

    let removeFromPort = newQty==0 ? true : false
    console.log("remove from port:", removeFromPort)

    if (removeFromPort){
        var tickerToRemove = tickerToUpdate;
        tickerToRemove = tickerToRemove.toUpperCase();
        let documents = await collection.find({}).toArray();
        let portfolioArray = documents[0]['portfolio'];
        let portFinal = portfolioArray.map(item => JSON.parse(item));
        let modifiedPortfolio = portFinal.filter(item => item.ticker !== tickerToRemove);
        let stringifiedPortfolio = modifiedPortfolio.map(item => JSON.stringify(item));
        let docId = documents[0]['_id'];
        await collection.updateOne(
        { _id: docId },
        { $set: { portfolio: stringifiedPortfolio } }
        );
    }
    res.send(portFinal);
})


app.get("/removePortfolioElement/:ticker", async(req,res)=>{
    var tickerToRemove = req.params.ticker;
    tickerToRemove = tickerToRemove.toUpperCase();
    console.log("inside remove port ele:", tickerToRemove);

    let documents = await collection.find({}).toArray();
    let portfolioArray = documents[0]['portfolio'];
    let portFinal = portfolioArray.map(item => JSON.parse(item));
    let modifiedPortfolio = portFinal.filter(item => item.ticker !== tickerToRemove);
    console.log("modified port:", modifiedPortfolio)
    let stringifiedPortfolio = modifiedPortfolio.map(item => JSON.stringify(item));
    console.log("stringified: ", stringifiedPortfolio)
    let docId = documents[0]['_id'];
    await collection.updateOne(
    { _id: docId },
    { $set: { portfolio: stringifiedPortfolio } }
    );
    res.send(portFinal);
})


app.get("/portfolio/update/:ticker/:qtyPurchased/:newAvgCost/:tickername", async(req,res)=>{
    var tickerToUpdate = req.params.ticker;
    var newQty = req.params.qtyPurchased;
    var newAvgCost = req.params.newAvgCost;
    var name = req.params.tickername;
    var updatedPortElement = {}
    updatedPortElement.ticker = tickerToUpdate;
    updatedPortElement.name = name;
    updatedPortElement.qty = newQty;
    updatedPortElement.avgCost = newAvgCost;
    // let tickerToUpdate = updatedPortElement.ticker;
    // let newQty = updatedPortElement.qty; 
    // let newAvgCost = updatedPortElement.avgCost; 
    // let name = updatedPortElement.name;

    let documents = await collection.find({}).toArray();
    let portfolioArray = documents[0]['portfolio'];
    let portFinal = portfolioArray.map(item => JSON.parse(item));
    if(newQty == 0){
        let modifiedPortfolio = portFinal.filter(item => item.ticker !== tickerToUpdate);
        console.log("modified port:", modifiedPortfolio)
        let stringifiedPortfolio = modifiedPortfolio.map(item => JSON.stringify(item));
        console.log("stringified: ", stringifiedPortfolio)
        let docId = documents[0]['_id'];
        await collection.updateOne(
        { _id: docId },
        { $set: { portfolio: stringifiedPortfolio } }
        );
        res.send(portFinal);
    }
    else{
            let index = portFinal.findIndex(item => item.ticker === tickerToUpdate);
            if (index !== -1) {
                portFinal[index].qty = newQty;
                portFinal[index].avgCost = newAvgCost;
            } else {
                portFinal.push({ ticker: tickerToUpdate, name : name, qty: newQty, avgCost: newAvgCost });
            }

            let updatedPortfolioArray = portFinal.map(item => JSON.stringify(item));

            let docId = documents[0]['_id'];

            await collection.updateOne(
                { _id: docId },
                { $set: { portfolio: updatedPortfolioArray } }
            );
            res.send(portFinal);
        }
   
})


app.get("/isStockInPortfolio/:ticker", async(req,res)=>{
    // await connectToMongoDB();

    var ticker = req.params.ticker;
    ticker = ticker.toUpperCase();
    documents = await collection.find({}).toArray();
    portfolioArray = documents[0]['portfolio'];
    var portFinal = portfolioArray.map(item => JSON.parse(item));
    var portfolioDataOfStock = portFinal.find(obj => obj.ticker === ticker) || {};
    res.send(portfolioDataOfStock);
})
