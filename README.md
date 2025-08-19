# HalfTrend Indicator for MetaTrader 4 & 5

An advanced trend-following indicator that combines trend detection with dynamic channels and signal arrows. Perfect for identifying trend changes, entries, and managing positions with clear visual signals.

## Description

Advanced HalfTrend indicator with ATR-based channels for MT4/MT5. Features automatic trend detection, buy/sell signal arrows, and dynamic support/resistance channels. Uses amplitude filtering and channel deviation for precise trend identification. Perfect for trend following and swing trading strategies. Educational tool with risk warnings included.

The HalfTrend indicator provides comprehensive trend analysis by displaying:
- **Trend Lines**: Clear buy (green) and sell (red) trend lines
- **Signal Arrows**: Triangle arrows marking trend change points
- **Dynamic Channels**: ATR-based support and resistance channels
- **Trend Detection**: Advanced algorithm using moving averages and price action
- **Visual Clarity**: Color-coded lines for easy trend identification

This sophisticated indicator works on both MetaTrader 4 and MetaTrader 5 platforms, providing traders with professional-grade trend analysis tools.

## Features

- ✅ Compatible with both **MetaTrader 4** and **MetaTrader 5**
- ✅ **Advanced trend detection** using amplitude filtering
- ✅ **Dynamic ATR-based channels** for support/resistance
- ✅ **Signal arrows** marking trend change points
- ✅ **Customizable colors** for buy and sell signals
- ✅ **Toggle options** for arrows and channels
- ✅ **Real-time updates** as trends develop
- ✅ **Works on all timeframes** and instruments
- ✅ **Multiple ATR calculations** for accuracy
- ✅ **Clean visual design** with minimal chart clutter

## Installation

### For MetaTrader 5:
1. Download the `.mq5` file
2. Copy to: `MT5 Data Folder/MQL5/Indicators/`
3. Restart MT5 or refresh Navigator
4. Find "HalfTrend" in Custom Indicators
5. Drag and drop onto your chart

### For MetaTrader 4:
1. Download the `.mq4` file
2. Copy to: `MT4 Data Folder/MQL4/Indicators/`
3. Restart MT4 or refresh Navigator
4. Find "HalfTrend" in Custom Indicators
5. Drag and drop onto your chart

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `amplitude` | 2 | Amplitude for trend sensitivity (higher = less sensitive) |
| `channelDeviation` | 2 | Channel width multiplier for ATR-based channels |
| `showArrows` | true | Display triangle arrows at trend change points |
| `showChannels` | true | Display dynamic support/resistance channels |
| `buyColor` | Green | Color for bullish trend lines |
| `sellColor` | Red | Color for bearish trend lines |

## How It Works

### Trend Detection Algorithm
1. **Amplitude Analysis**: Uses moving averages of high/low prices
2. **Price Action Confirmation**: Confirms trends with close price validation
3. **ATR Filtering**: Uses multiple ATR periods (100 and 360) for noise reduction
4. **Dynamic Levels**: Calculates support/resistance based on recent price action

### Signal Generation
- **Buy Signal**: Generated when trend changes from bearish to bullish
- **Sell Signal**: Generated when trend changes from bullish to bearish
- **Trend Continuation**: Maintains current trend line during trending phases
- **Channel Boundaries**: Provides dynamic support/resistance levels

### Visual Components
- **Green Line**: Bullish trend (HT Buy)
- **Red Line**: Bearish trend (HT Sell)
- **Blue Dotted Line**: Upper channel boundary (atrHigh)
- **Salmon Dotted Line**: Lower channel boundary (atrLow)
- **Green Triangles**: Buy signal arrows
- **Red Triangles**: Sell signal arrows

## Trading Applications

### Trend Following
- **Primary Trend**: Follow green lines for bullish trends, red for bearish
- **Trend Changes**: Enter on triangle arrow signals
- **Trend Strength**: Use channel width to gauge trend strength
- **Position Management**: Hold positions while trend line continues

### Channel Trading
- **Support/Resistance**: Use channel boundaries as key levels
- **Breakout Signals**: Watch for breaks above/below channels
- **Range Trading**: Trade bounces within channel boundaries
- **Risk Management**: Use channels for stop loss placement

### Entry Strategies
- **Trend Change Entries**: Enter on triangle arrow signals
- **Pullback Entries**: Buy pullbacks to green trend line, sell rallies to red line
- **Channel Breakouts**: Enter on breaks of channel boundaries
- **Confirmation Entries**: Wait for trend line to establish before entering

### Exit Strategies
- **Trend Reversal**: Exit when opposite color triangle appears
- **Channel Breaks**: Exit when price breaks opposite channel
- **Time-based**: Exit after predetermined time in trend
- **Profit Targets**: Use channel boundaries as profit targets

## Visual Elements

### Trend Lines
- **Buy Trend**: Green solid line, width 2
- **Sell Trend**: Red solid line, width 2
- **Dynamic**: Updates in real-time with price action

### Channel Lines
- **Upper Channel**: Blue dotted line (atrHigh)
- **Lower Channel**: Salmon dotted line (atrLow)
- **Width**: Based on ATR and channel deviation setting

### Signal Arrows
- **Buy Arrows**: Green triangles below price
- **Sell Arrows**: Red triangles above price
- **Positioning**: Placed relative to trend lines and ATR

## Parameter Optimization

### Amplitude Settings
- **Low Values (1-2)**: More sensitive, more signals, more noise
- **Medium Values (2-4)**: Balanced sensitivity and reliability
- **High Values (5+)**: Less sensitive, fewer signals, more reliable

### Channel Deviation
- **Low Values (1-1.5)**: Tighter channels, more breakout signals
- **Medium Values (2-3)**: Standard channel width
- **High Values (4+)**: Wider channels, fewer false breakouts

### Timeframe Considerations
- **Lower Timeframes (M1-M15)**: Use lower amplitude for responsiveness
- **Medium Timeframes (M30-H4)**: Standard settings work well
- **Higher Timeframes (D1+)**: Can use higher amplitude for major trends

## Compatibility

| Platform | Version | Status |
|----------|---------|---------|
| MetaTrader 4 | Build 1380+ | ✅ Supported |
| MetaTrader 5 | Build 3440+ | ✅ Supported |
| All Timeframes | M1 to MN1 | ✅ Compatible |
| All Instruments | Forex, Stocks, Crypto, Commodities | ✅ Compatible |
| Chart Types | Candlestick, Bar, Line | ✅ Compatible |

## Performance Features

- **Efficient Calculation**: Optimized algorithms for real-time performance
- **Memory Management**: Automatic cleanup of outdated objects
- **Visual Optimization**: Clean display without chart clutter
- **Resource Friendly**: Minimal CPU and memory usage

## Usage Tips

### Best Practices
1. **Combine with other indicators** for confirmation
2. **Adjust amplitude** based on market volatility
3. **Use channels** for entry and exit points
4. **Wait for arrow confirmation** before entering trades

### Trading Strategies
- **Trend Following**: Follow the dominant color trend line
- **Reversal Trading**: Enter on triangle arrow signals
- **Channel Bounces**: Trade rebounds from channel boundaries
- **Breakout Trading**: Trade breaks of established channels

### Risk Management
- **Stop Losses**: Place beyond opposite channel boundary
- **Position Sizing**: Adjust based on channel width
- **Trend Confirmation**: Wait for multiple confirmations
- **Market Conditions**: Adapt strategy to trending vs. ranging markets

## Common Trading Scenarios

### Strong Trending Market
- **Follow trend lines** continuously
- **Ignore minor channel touches**
- **Hold positions** until trend change arrow

### Choppy/Ranging Market
- **Trade channel bounces**
- **Reduce position sizes**
- **Take quick profits**
- **Watch for breakout signals**

### Trend Reversal
- **Wait for triangle arrow**
- **Confirm with price action**
- **Enter on new trend establishment**
- **Manage previous positions**

## Version History

- **v1.05** - Enhanced stability and MT4/MT5 compatibility
- **v1.04** - Improved ATR calculations and channel accuracy
- **v1.03** - Added toggle options for arrows and channels
- **v1.02** - Enhanced trend detection algorithm
- **v1.01** - Initial release

## Technical Requirements

### Minimum System Requirements
- MetaTrader 4 (Build 1380+) or MetaTrader 5 (Build 3440+)
- Windows 7/8/10/11 or compatible system
- 100MB available storage space
- Stable internet connection for real-time analysis

## Advanced Features

### Multi-ATR Analysis
- **360-period ATR**: Long-term volatility measurement
- **100-period ATR**: Short-term volatility for channels
- **Dynamic Adjustment**: Adapts to changing market conditions

### Intelligent Trend Detection
- **High/Low MA**: Uses moving averages of extreme prices
- **Price Confirmation**: Validates trends with close price analysis
- **Noise Filtering**: Eliminates false signals through amplitude control

### Visual Intelligence
- **Automatic Coloring**: Trends automatically color-coded
- **Clean Transitions**: Smooth trend line transitions
- **Optimal Positioning**: Arrows placed for maximum visibility

## Risk Warning

⚠️ **Important Disclaimer**: 
- Trading involves substantial risk of loss
- Past performance doesn't guarantee future results
- This indicator is for educational purposes only
- Always use proper risk management
- Never risk more than you can afford to lose
- Trend indicators can give false signals
- Market conditions affect indicator performance
- Consider seeking professional financial advice
- No indicator guarantees profitable trades

## Support & Resources

- 🌐 **Website**: [TradingFinder.com](https://tradingfinder.com)
- 📊 **More Indicators**: [MT4/MT5 Products](https://tradingfinder.com/products/indicators/)
- 📚 **Trading Education**: Available on our website

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.


**Developed by TFLab | TradingFinder.com**  
*Empowering traders with professional-grade technical analysis tools*
