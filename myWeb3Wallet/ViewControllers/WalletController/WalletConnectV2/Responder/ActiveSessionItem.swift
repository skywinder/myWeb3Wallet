struct ActiveSessionItem {
    let dappName: String
    let dappURL: String
    let iconURL: String
    let topic: String
}

extension ActiveSessionItem {
    
    static func mockList() -> [ActiveSessionItem] {
        [mockPancakeSwap(), mockUniswap(), mockSushiSwap()]
    }
    
    static func mockPancakeSwap() -> ActiveSessionItem {
        ActiveSessionItem(
            dappName: "PancakeSwap",
            dappURL: "https://exchange.pancakeswap.finance",
            iconURL: "https://pancakeswap.finance/logo.png",
            topic: "14ac2dd98734df10ee417d46ad6db7a7137b14fb9a9520af107e284299763245"
        )
    }
    
    static func mockUniswap() -> ActiveSessionItem {
        ActiveSessionItem(
            dappName: "Uniswap",
            dappURL: "app.uniswap.org",
            iconURL: "https://s2.coinmarketcap.com/static/img/coins/64x64/7083.png",
            topic: "14ac2dd98734df10ee417d46ad6db7a7137b14fb9a9520af107e284299763245"
        )
    }
    
    static func mockSushiSwap() -> ActiveSessionItem {
        ActiveSessionItem(
            dappName: "Sushi Swap",
            dappURL: "app.sushi.com",
            iconURL: "https://s2.coinmarketcap.com/static/img/coins/64x64/6758.png",
            topic: "14ac2dd98734df10ee417d46ad6db7a7137b14fb9a9520af107e284299763245"
        )
    }
}
