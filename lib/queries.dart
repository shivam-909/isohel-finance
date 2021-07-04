final String login = """
mutation Login(\$usernameOrEmail: String!, \$password: String!) {
  login(usernameOrEmail:\$usernameOrEmail, password:\$password){
    user{
      username
    }
  }
}

""";

final String me = """
query me {
  Me{
    username
    isMonzo
    isAlpaca
  }
}
""";

final String stocksNews = """
query stocksNews {
  stocksNews
}
""";

final String searchAssets = """
mutation searchAssets(\$symbol: String!) {
  searchAssets(symbol: \$symbol) {
    symbol
    name
    exchange
  }
}
""";

final String placeOrder = """
mutation placeOrder(\$options: OrderOptions!) {
  placeOrder(options: \$options)
}
""";

final String getMonzoRedirect = """
query getMonzoRedirect {
  getMonzoRedirect
}

""";

final String getAlpacaRedirect = """
query getAlpacaRedirect {
  getAlpacaRedirect
}

""";

final String portfolioChart = """
query portfolioChart {
  getPortfolioHistoryPaper
}
""";

final String monzoComplete = """
query monzoComplete {
  monzoComplete
}
""";

final String alpacaSummary = """
query getAlpacaAccountPaper {
  getAlpacaAccountPaper
}
""";

final String alpacaPositions = """
query getAlpacaPositionsPaper {
  getAlpacaPositionsPaper
}
""";

final String readPortfolios = """
query readPortfolio {
  readPortfolio
}
""";

final String getMonzoLink = """
query getMonzoRedirect {
  getMonzoRedirect
}
""";

final String register = """
mutation register(\$username: String!, \$password:String!, \$email: String!){
  register(options:{
    username:\$username,
    password:\$password,
    email: \$email
  })
}""";

final String getAssetInfo = """
query getAssetInfo(\$symbol: String!) {
  getAssetInfo(symbol: \$symbol) {
    class
    exchange
    symbol
    name
    tradable
    marginable
    shortable
    easy_to_borrow
  }
}
""";
