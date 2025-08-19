//+------------------------------------------------------------------+
//|                                                    HalfTrend.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "TradingFinder.com - 2025"
#property link      "https://tradingfinder.com/products/indicators/mt5/"
#property version   "1.05"
#property description ""
#property description "Risk Warning: Trading in financial markets involves risk, and you may lose part or all of your money. Using this indicator is at your own risk. we create software for educational purposes. We are not responsible for any losses or damages."
#property description ""
#property description "Find out more on TradingFinder.com"
#property icon    "\\Images\\Logo.ico"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//+------------------------------------------------------------------+
//|                  inputs and variables                            |
//+------------------------------------------------------------------+
input int amplitude = 2;//Amplitude
input int channelDeviation = 2;//Channel Deviation
input bool showArrows = true;//Show Arrows
input bool showChannels = true;//Show Channels
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

double perv_up = NULL;
double up = NULL;

double perv_down = NULL;
double down = NULL;

datetime perv_candle_time = NULL;

double arrowUp = NULL;
double arrowDown = NULL;

int atr_handle;
double atr_buffer[];

datetime one_candle_time = NULL;
int object_counter = 0;
bool triangle_draw_done = false;

int atr2_handle;
double atr2_buffer[];

double dev = NULL;
double highPrice = NULL;
double lowPrice = NULL;

int highma_handle;
double highma_buffer[];

int lowma_handle;
double lowma_buffer[];

bool buySignal = false;
bool sellSignal = false;

bool first_run = false;
int last_rates_total = NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ArrayFree(ht);
   ArrayFree(ht_buy);
   ArrayFree(ht_sell);
   ArrayFree(atrHigh);
   ArrayFree(atrLow);

   ArrayFree(atr_buffer);
   ArrayFree(atr2_buffer);
   ArrayFree(highma_buffer);
   ArrayFree(lowma_buffer);

   SetIndexBuffer(0, ht);
   SetIndexBuffer(1, ht_buy);
   SetIndexBuffer(2, ht_sell);
   SetIndexBuffer(3, atrHigh);
   SetIndexBuffer(4, atrLow);

   ArraySetAsSeries(ht, true);
   ArraySetAsSeries(ht_buy, true);
   ArraySetAsSeries(ht_sell, true);
   ArraySetAsSeries(atrHigh, true);
   ArraySetAsSeries(atrLow, true);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetString(0, PLOT_LABEL, "HT");

   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, buyColor);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(1, PLOT_LABEL, "HT Buy");

   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, sellColor);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(2, PLOT_LABEL, "HT Sell");

   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrCornflowerBlue);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(3, PLOT_LABEL, "atrHigh");

   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, clrSalmon);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(4, PLOT_LABEL, "atrLow");

   maxLowPrice = iLow(Symbol(), PERIOD_CURRENT, 1);
   minHighPrice = iHigh(Symbol(), PERIOD_CURRENT, 1);
   one_candle_time = iTime(Symbol(), PERIOD_CURRENT, 1) - iTime(Symbol(), PERIOD_CURRENT, 2);

   atr_handle = iATR(Symbol(), PERIOD_CURRENT, 360);

   atr2_handle = iATR(Symbol(), PERIOD_CURRENT, 100);

   highma_handle = iMA(Symbol(), PERIOD_CURRENT, amplitude, 0, MODE_SMA, PRICE_HIGH);

   lowma_handle = iMA(Symbol(), PERIOD_CURRENT, amplitude, 0, MODE_SMA, PRICE_LOW);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|              on deinit                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int loop = 1000000;

   object_delete(loop, "CB_HTTriangle");

   IndicatorRelease(atr_handle);
   IndicatorRelease(atr2_handle);
   IndicatorRelease(highma_handle);
   IndicatorRelease(lowma_handle);
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

   if(first_run == false)
     {
      for(int i = MathMin(rates_total - MathMax(amplitude, 5),  TerminalInfoInteger(TERMINAL_MAXBARS) - MathMax(amplitude, 5)); i >= 1; i--)
        {
         update_values(i);
         calc_values_every_bar(i);
         function1(i);
         function2(i);
         function3(i);
         function4(i);
        }

      first_run = true;
     }

   if(first_run == true)
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
   ObjectCreate(ChartID(), "CB_HTTriangle" + IntegerToString(object_counter), OBJ_TRIANGLE, 0, time1, price1, time2, price2, time3, price3);
   ObjectSetInteger(ChartID(), "CB_HTTriangle" + IntegerToString(object_counter), OBJPROP_COLOR, _color);
   ObjectSetInteger(ChartID(), "CB_HTTriangle" + IntegerToString(object_counter), OBJPROP_SELECTABLE, false);
   ObjectSetInteger(ChartID(), "CB_HTTriangle" + IntegerToString(object_counter), OBJPROP_FILL, true);
   object_counter += 1;
   return "CB_HTTriangle" + IntegerToString(object_counter - 1);
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
         triangle_draw_done = false;
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calc_values_every_bar(int i)
  {
   CopyBuffer(atr_handle, 0, i, 1, atr_buffer);
   CopyBuffer(atr2_handle, 0, i, 1, atr2_buffer);
   CopyBuffer(highma_handle, 0, i, 1, highma_buffer);
   CopyBuffer(lowma_handle, 0, i, 1, lowma_buffer);
   dev = channelDeviation * (atr2_buffer[0] / 2);
   highPrice = iHigh(Symbol(), PERIOD_CURRENT, iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, amplitude, i));
   lowPrice = iLow(Symbol(), PERIOD_CURRENT, iLowest(Symbol(), PERIOD_CURRENT, MODE_LOW, amplitude, i));
  }
//+------------------------------------------------------------------+
//|                      functions                                   |
//+------------------------------------------------------------------+
void function1(int i)
  {
   if(nextTrend == 1)
     {
      maxLowPrice = MathMax(lowPrice, maxLowPrice);
      if(highma_buffer[0] < maxLowPrice && iClose(Symbol(), PERIOD_CURRENT, i) < iLow(Symbol(), PERIOD_CURRENT, i + 1))
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
         if(lowma_buffer[0] > minHighPrice && iClose(Symbol(), PERIOD_CURRENT, i) > iHigh(Symbol(), PERIOD_CURRENT, i + 1))
           {
            trend = 0;
            nextTrend = 1;
            maxLowPrice = lowPrice;
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void function2(int i)
  {
   if(trend == 0)
     {
      if(perv_trend == 1)
        {
         if(perv_down == NULL)
           {
            up = down;
           }
         else
           {
            up = perv_down;
           }
         arrowUp = up - atr2_buffer[0];
        }
      else
        {
         if(perv_up == NULL)
           {
            up = maxLowPrice;
           }
         else
           {
            up = MathMax(maxLowPrice, perv_up);
           }
        }
      if(showChannels == true)
        {
         atrHigh[i - 1] = up + dev;
         atrLow[i - 1] = up - dev;

         atrHigh[i] = atrHigh[i - 1];
         atrLow[i] = atrLow[i - 1];
        }
      else
        {
         atrHigh[i - 1] = EMPTY_VALUE;
         atrLow[i - 1] = EMPTY_VALUE;
        }
     }
   else
      if(trend == 1)
        {
         if(perv_trend == 0)
           {
            if(perv_up == NULL)
              {
               down = up;
              }
            else
              {
               down = perv_up;
              }
            arrowDown = down + atr2_buffer[0];
           }
         else
           {
            if(perv_down == NULL)
              {
               down = minHighPrice;
              }
            else
              {
               down = MathMin(minHighPrice, perv_down);
              }
            if(showChannels == true)
              {
               atrHigh[i - 1] = down + dev;
               atrLow[i - 1] = down - dev;

               atrHigh[i] = atrHigh[i - 1];
               atrLow[i] = atrLow[i - 1];
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
      ht_buy[i] = ht[i - 1];
      ht_buy[i - 1] = ht[i - 1];
      ht_sell[i - 1] = EMPTY_VALUE;
     }
   else
     {
      ht[i - 1] = down;
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
   if(trend == 0 && perv_trend == 1)
     {
      buySignal = true;
      if(triangle_draw_done == false && showArrows == true)
        {
         triangle_creator(down - dev, iTime(Symbol(), PERIOD_CURRENT, i), down - dev - atr_buffer[0], iTime(Symbol(), PERIOD_CURRENT, i) - one_candle_time, down - dev - atr_buffer[0], iTime(Symbol(), PERIOD_CURRENT, i) + one_candle_time, clrGreen);
         triangle_draw_done = true;
        }
     }
   else
     {
      buySignal = false;
     }
   if(trend == 1 && perv_trend == 0)
     {
      sellSignal = true;
      if(triangle_draw_done == false && showArrows == true)
        {
         triangle_creator(up + dev, iTime(Symbol(), PERIOD_CURRENT, i), up + dev + atr_buffer[0], iTime(Symbol(), PERIOD_CURRENT, i) - one_candle_time, up + dev + atr_buffer[0], iTime(Symbol(), PERIOD_CURRENT, i) + one_candle_time, clrRed);
         triangle_draw_done = true;
        }
     }
   else
     {
      sellSignal = false;
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

   ArraySetAsSeries(ht, true);
   ArraySetAsSeries(ht_buy, true);
   ArraySetAsSeries(ht_sell, true);
   ArraySetAsSeries(atrHigh, true);
   ArraySetAsSeries(atrLow, true);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetString(0, PLOT_LABEL, "HT");

   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, buyColor);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(1, PLOT_LABEL, "HT Buy");

   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, sellColor);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(2, PLOT_LABEL, "HT Sell");

   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrCornflowerBlue);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(3, PLOT_LABEL, "atrHigh");

   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, clrSalmon);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(4, PLOT_LABEL, "atrLow");

   perv_trend = 0;
   trend = 0;

   perv_up = NULL;
   up = NULL;

   perv_down = NULL;
   down = NULL;

   perv_candle_time = NULL;

   arrowUp = NULL;
   arrowDown = NULL;

   object_counter = 0;
   triangle_draw_done = false;

   atr2_buffer[0] = NULL;
   dev = NULL;
   highPrice = NULL;
   lowPrice = NULL;
   highma_buffer[0] = NULL;
   lowma_buffer[0] = NULL;

   buySignal = false;
   sellSignal = false;

   first_run = false;
   last_rates_total = NULL;

   int loop = 1000000;

   object_delete(loop, "CB_HTTriangle");
  }
