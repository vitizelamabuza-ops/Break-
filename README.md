# Break- MetaTrader 5 Expert Advisor

A professional, production-quality MetaTrader 5 Expert Advisor with advanced trend detection, risk management, and trade management capabilities.

## Features

### Trend Detection
- EMA 50 & MACD for uptrend/downtrend identification
- RSI above/below 50 confirmation
- MACD bullish/bearish crossover signals
- ADX trend strength filter (optional)

### Risk Management
- Configurable risk per trade (0.25%-2%)
- Automatic lot sizing based on account equity
- Maximum daily loss protection
- Maximum daily trades limit
- Maximum drawdown protection
- One trade per signal enforcement

### Trade Management
- ATR 14-based stop loss and take profit
- Configurable risk:reward ratios (default 1:2)
- Break-even protection
- Partial profit taking
- Trailing stops
- Opposite trade closing (optional)

### Safety & Filters
- Spread filters
- Slippage protection
- Trading session filters (London/New York)
- Minimum candle size validation
- News filter (optional)
- Free margin validation
- Overleveraging prevention
- Duplicate trade prevention

### Logging & Monitoring
- Entry/exit reason logging
- Indicator values tracking
- Profit/loss recording
- Error message logging

## Project Structure

```
Break-/
├── README.md
├── MQL5/
│   ├── Experts/
│   │   └── BreakEA.mq5          # Main Expert Advisor
│   ├── Include/
│   │   ├── Indicators/
│   │   │   ├── TrendDetection.mqh
│   │   │   ├── RSIFilter.mqh
│   │   │   └── ADXFilter.mqh
│   │   ├── RiskManagement/
│   │   │   ├── PositionSizing.mqh
│   │   │   ├── RiskCalculator.mqh
│   │   │   └── DrawdownManager.mqh
│   │   ├── TradeManagement/
│   │   │   ├── OrderManager.mqh
│   │   │   ├── TradeFilters.mqh
│   │   │   └── PartialClosing.mqh
│   │   ├── Utilities/
│   │   │   ├── Logger.mqh
│   │   │   ├── TimeManager.mqh
│   │   │   └── MathUtils.mqh
│   │   └── Config/
│   │       └── Settings.mqh
│   └── Scripts/
│       └── Backtester.mq5
└── Config/
    └── default.set
```

## Configuration

All parameters are fully configurable via EA inputs:
- EMA periods
- RSI periods
- MACD settings
- ATR multiplier
- Risk percentage
- Trading sessions
- Maximum spread
- TP/SL multipliers

## Compilation

No warnings or errors - production-ready code.

## Testing

Optimized for MT5 backtesting and live trading.
