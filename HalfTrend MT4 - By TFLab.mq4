//+------------------------------------------------------------------+
//|                                                    HalfTrend.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "TradingFinder.com - 2023-2024"
#property link      "https://tradingfinder.com/products/indicators/mt4/"
#property version   "1.04"
#property description "Risk Warning: Trading on financial markets involves risk, and you may lose part or all of your money. Using this indicator is at your own risk. TradingFinder [TFLab] creates software as educational material. We are not responsible for any losses or damages."
#property description "   "
#property description "Find out more on TradingFinder.com"
#property icon    "\\Images\\Logo.ico"

#property strict
#property indicator_chart_window
#property indicator_buffers 5

//+------------------------------------------------------------------+
//|                  inputs and variables                            |
//+------------------------------------------------------------------+
input int amplitude = 2;//Amplitude
input int channelDeviation = 2;//Channel Deviation
input bool showArrows = True;//Show Arrows
input bool showChannels = True;//Show Channels
input color buyColor = clrGreen;//buy Color
input color sellColor = clrRed;//sell Color


int nextTrend = 0;
double maxLowPrice = NULL;
double minHighPrice = NULL;

double ht[];
double ht_buy[];
double ht_sell[];
double atrHigh[];
double atrLow[];


int perv_trend = 0;
int trend = 0;

double perv_up = 0;
double up = 0;

double perv_down = 0;
double down = 0;

datetime perv_candle_time = NULL;

double arrowUp = NULL;
double arrowDown = NULL;

double atr = NULL;
datetime one_candle_time = NULL;
int object_counter = 0;
bool triangle_draw_done = False;

double atr2 = NULL;
double dev = NULL;
double highPrice = NULL;
double lowPrice = NULL;
double highma = NULL;
double lowma = NULL;

bool buySignal = False;
bool sellSignal = False;

bool first_run = False;
int last_rates_total = NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0, ht);
   SetIndexBuffer(1, ht_buy);
   SetIndexBuffer(2, ht_sell);
   SetIndexBuffer(3, atrHigh);
   SetIndexBuffer(4, atrLow);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, buyColor);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2, sellColor);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, clrCornflowerBlue);
   SetIndexStyle(4, DRAW_LINE, STYLE_DOT, 1, clrSalmon);

   SetIndexLabel(0,"HT");
   SetIndexLabel(1,"HT Buy");
   SetIndexLabel(2,"HT Sell");
   SetIndexLabel(3,"atrHigh");
   SetIndexLabel(4,"atrLow");

   maxLowPrice = iLow(Symbol(), PERIOD_CURRENT, 1);
   minHighPrice = iHigh(Symbol(), PERIOD_CURRENT, 1);

   atr = iATR(Symbol(), PERIOD_CURRENT, 360, 0);
   one_candle_time = iTime(Symbol(), PERIOD_CURRENT, 1) - iTime(Symbol(), PERIOD_CURRENT, 2);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|              on deinit                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int loop = 1000000;

   object_delete(loop, "HTTriangle");
  }
//+------------------------------------------------------------------+
//|                     delete objects                               |
//+------------------------------------------------------------------+
void object_delete(int iter, string name)
  {
   for(int i = iter; i >= 0; i--)
     {
      string obj_name = name + IntegerToString(i);
      bool od = ObjectDelete(ChartID(), obj_name);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(last_rates_total == NULL)
     {
      last_rates_total = rates_total;
     }
   if(rates_total - last_rates_total == 1)
     {
      last_rates_total = rates_total;
     }
   if(rates_total - last_rates_total > 1)
     {
      reset_every_thing();
     }

   if(first_run == False)
     {
      for(int i = rates_total - MathMax(amplitude, 5); i >= 1; i--)
        {
         update_values(i);
         calc_values_every_bar(i);
         function1(i);
         function2(i);
         function3(i);
         function4(i);
        }

      first_run = True;
     }

   if(first_run == True)
     {
      update_values(1);
      calc_values_every_bar(1);
      function1(1);
      function2(1);
      function3(1);
      function4(1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                    create objects                                |
//+------------------------------------------------------------------+
//triangle
string triangle_creator(double price1, datetime time1, double price2, datetime time2, double price3, datetime time3, color _color)
  {
   ObjectCreate(ChartID(), "HTTriangle" + IntegerToString(object_counter), OBJ_TRIANGLE, 0, time1, price1, time2, price2, time3, price3);
   ObjectSetInteger(ChartID(), "HTTriangle" + IntegerToString(object_counter), OBJPROP_COLOR, _color);
   ObjectSetInteger(ChartID(), "HTTriangle" + IntegerToString(object_counter), OBJPROP_SELECTABLE, False);
   object_counter += 1;
   return "HTTriangle" + IntegerToString(object_counter - 1);
  }
//+------------------------------------------------------------------+
//|                  calculate values every bar                      |
//+------------------------------------------------------------------+
void update_values(int i)
  {
   if(perv_candle_time == NULL)
     {
      perv_candle_time = iTime(Symbol(), PERIOD_CURRENT, i);
     }
   else
      if(perv_candle_time != iTime(Symbol(), PERIOD_CURRENT, i))
        {
         perv_candle_time = iTime(Symbol(), PERIOD_CURRENT, i);

         perv_down = down;
         perv_up = up;
         perv_trend = trend;
         triangle_draw_done = False;
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calc_values_every_bar(int i)
  {
   atr2 = iATR(Symbol(), PERIOD_CURRENT, 100, i) / 2;
   dev = channelDeviation * atr2;
   highPrice = iHigh(Symbol(), PERIOD_CURRENT, iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, amplitude, i));
   lowPrice = iLow(Symbol(), PERIOD_CURRENT, iLowest(Symbol(), PERIOD_CURRENT, MODE_LOW, amplitude, i));
   highma = iMA(Symbol(), PERIOD_CURRENT, amplitude, 0, MODE_SMA, PRICE_HIGH, i);
   lowma = iMA(Symbol(), PERIOD_CURRENT, amplitude, 0, MODE_SMA, PRICE_LOW, i);
  }
//+------------------------------------------------------------------+
//|                      functions                                   |
//+------------------------------------------------------------------+
void function1(int i)
  {
   if(nextTrend == 1)
     {
      maxLowPrice = MathMax(lowPrice, maxLowPrice);
      if(highma < maxLowPrice && iClose(Symbol(), PERIOD_CURRENT, i) < iLow(Symbol(), PERIOD_CURRENT, i + 1))
        {
         trend = 1;
         nextTrend = 0;
         minHighPrice = highPrice;
        }
     }
   else
      if(nextTrend == 0)
        {
         minHighPrice = MathMin(highPrice, minHighPrice);
         if(lowma > minHighPrice && iClose(Symbol(), PERIOD_CURRENT, i) > iHigh(Symbol(), PERIOD_CURRENT, i + 1))
           {
            trend = 0;
            nextTrend = 1;
            maxLowPrice = lowPrice;
           }
        }
      else
         if(trend == EMPTY_VALUE)
           {
            trend = perv_trend;
           }
         else
            if(trend == EMPTY_VALUE && perv_trend == 0)
              {
               perv_trend = 0;
               trend = perv_trend;
              }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void function2(int i)
  {
   if(trend == 0)
     {
      if(perv_trend != EMPTY_VALUE && perv_trend != 0)
        {
         if(perv_down == EMPTY_VALUE)
           {
            up = down;
           }
         else
           {
            up = perv_down;
           }
         arrowUp = up - atr2;
        }
      else
        {
         if(perv_up == EMPTY_VALUE)
           {
            up = maxLowPrice;
           }
         else
           {
            up = MathMax(maxLowPrice, perv_up);
           }
        }
      if(showChannels == True)
        {
         atrHigh[i - 1] = up + dev;
         atrLow[i - 1] = up - dev;
        }
      else
        {
         atrHigh[i - 1] = EMPTY_VALUE;
         atrLow[i - 1] = EMPTY_VALUE;
        }
     }
   else
     {
      if(perv_trend != EMPTY_VALUE && perv_trend != 1)
        {
         if(perv_up == EMPTY_VALUE)
           {
            down = up;
           }
         else
           {
            down = perv_up;
           }
         arrowDown = down + atr2;
        }
      else
        {
         if(perv_down == EMPTY_VALUE)
           {
            down = minHighPrice;
           }
         else
           {
            down = MathMin(minHighPrice, perv_down);
           }
         if(showChannels == True)
           {
            atrHigh[i - 1] = down + dev;
            atrLow[i - 1] = down - dev;
           }
         else
           {
            atrHigh[i - 1] = EMPTY_VALUE;
            atrLow[i - 1] = EMPTY_VALUE;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void function3(int i)
  {
   if(trend == 0)
     {
      ht[i - 1] = up;
     }
   else
     {
      ht[i - 1] = down;
     }
   if(trend == 0)
     {
      ht_buy[i] = ht[i - 1];
      ht_buy[i - 1] = ht[i - 1];
      ht_sell[i - 1] = EMPTY_VALUE;
     }
   else
     {
      ht_sell[i] = ht[i - 1];
      ht_sell[i - 1] = ht[i - 1];
      ht_buy[i - 1] = EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void function4(int i)
  {
   if(arrowUp != EMPTY_VALUE && trend == 0 && perv_trend == 1)
     {
      buySignal = True;
      if(triangle_draw_done == False && showArrows == True)
        {
         triangle_creator(down - dev, iTime(Symbol(), PERIOD_CURRENT, i), down - dev - atr, iTime(Symbol(), PERIOD_CURRENT, i) - one_candle_time, down - dev - atr, iTime(Symbol(), PERIOD_CURRENT, i) + one_candle_time, clrGreen);
         triangle_draw_done = True;
        }
     }
   else
     {
      buySignal = False;
     }
   if(arrowDown != EMPTY_VALUE && trend == 1 && perv_trend == 0)
     {
      sellSignal = True;
      if(triangle_draw_done == False && showArrows == True)
        {
         triangle_creator(up + dev, iTime(Symbol(), PERIOD_CURRENT, i), up + dev + atr, iTime(Symbol(), PERIOD_CURRENT, i) - one_candle_time, up + dev + atr, iTime(Symbol(), PERIOD_CURRENT, i) + one_candle_time, clrRed);
         triangle_draw_done = True;
        }
     }
   else
     {
      sellSignal = False;
     }
  }
//+------------------------------------------------------------------+
//|                  reset objects and values                        |
//+------------------------------------------------------------------+
void reset_every_thing()
  {
   nextTrend = 0;

   ArrayFree(ht);
   ArrayFree(ht_buy);
   ArrayFree(ht_sell);
   ArrayFree(atrHigh);
   ArrayFree(atrLow);

   SetIndexBuffer(0, ht);
   SetIndexBuffer(1, ht_buy);
   SetIndexBuffer(2, ht_sell);
   SetIndexBuffer(3, atrHigh);
   SetIndexBuffer(4, atrLow);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, buyColor);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2, sellColor);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, clrCornflowerBlue);
   SetIndexStyle(4, DRAW_LINE, STYLE_DOT, 1, clrSalmon);

   SetIndexLabel(0,"HT");
   SetIndexLabel(1,"HT Buy");
   SetIndexLabel(2,"HT Sell");
   SetIndexLabel(3,"atrHigh");
   SetIndexLabel(4,"atrLow");

   perv_trend = 0;
   trend = 0;

   perv_up = 0;
   up = 0;

   perv_down = 0;
   down = 0;

   perv_candle_time = NULL;

   arrowUp = NULL;
   arrowDown = NULL;

   object_counter = 0;
   triangle_draw_done = False;

   atr2 = NULL;
   dev = NULL;
   highPrice = NULL;
   lowPrice = NULL;
   highma = NULL;
   lowma = NULL;

   buySignal = False;
   sellSignal = False;

   first_run = False;
   last_rates_total = NULL;

   int loop = 1000000;

   object_delete(loop, "HTTriangle");
  }
