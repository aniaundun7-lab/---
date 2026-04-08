import Foundation

enum BotAction {
    case buy
    case ignore
    case sell

    static func random() -> BotAction {
        let actions: [BotAction] = [.buy, .ignore, .sell]
        return actions.randomElement()!
    }
}

struct MarketData {
    let price: Double
    let currency: String

    var priceWithCurrency: String {
        "\(price) \(currency)"
    }
}

protocol Output {
    func printBuy(_ data: MarketData)
    func printIgnore(_ data: MarketData)
    func printSell(_ data: MarketData)
    func printDeal(openPrice: Double, closePrice: Double, income: Double, currency: String)
    func printResult(balance: Double, currency: String)
}

struct ConsoleOutput: Output {
    func printBuy(_ data: MarketData) {
        print("\(data.priceWithCurrency) - BUY")
    }

    func printIgnore(_ data: MarketData) {
        print("\(data.priceWithCurrency) - IGNORE")
    }

    func printSell(_ data: MarketData) {
        print("\(data.priceWithCurrency) - SELL")
    }

    func printDeal(openPrice: Double, closePrice: Double, income: Double, currency: String) {
        print("DEAL: \(openPrice) -> \(closePrice), INCOME = \(income) \(currency)")
    }

    func printResult(balance: Double, currency: String) {
        print("FINAL BALANCE: \(balance) \(currency)")
    }
}

final class TradingSimulation {
    private var balance: Double = 0.0
    private var openBuyPrice: Double?

    private let currency: String
    private let output: Output

    init(currency: String, output: Output) {
        self.currency = currency
        self.output = output
    }

    func startSimulation(steps: Int = 11) {
        for _ in 0..<steps {
            let marketData = generateMarketDataForStep()
            let botAction = BotAction.random()
            processBotAction(botAction, marketData: marketData)
        }

        output.printResult(balance: balance, currency: currency)
    }
}

private extension TradingSimulation {
    func processBotAction(_ action: BotAction, marketData: MarketData) {
        switch action {
        case .buy:
            processBuy(marketData)
        case .ignore:
            processIgnore(marketData)
        case .sell:
            processSell(marketData)
        }
    }

    func processBuy(_ marketData: MarketData) {
        output.printBuy(marketData)

        // Open trade only if there is no open trade
        if openBuyPrice == nil {
            openBuyPrice = marketData.price
        }
    }

    func processIgnore(_ marketData: MarketData) {
        output.printIgnore(marketData)
    }

    func processSell(_ marketData: MarketData) {
        output.printSell(marketData)

        if let buyPrice = openBuyPrice {
            let income = marketData.price - buyPrice
            balance += income
            output.printDeal(
                openPrice: buyPrice,
                closePrice: marketData.price,
                income: income,
                currency: currency
            )
        }

        openBuyPrice = nil
    }

    func generateMarketDataForStep() -> MarketData {
        MarketData(price: generateRandomPrice(), currency: currency)
    }

    func generateRandomPrice() -> Double {
        Double.random(in: 11...16)
    }
}

let bot = TradingSimulation(currency: "CNY", output: ConsoleOutput())
bot.startSimulation()