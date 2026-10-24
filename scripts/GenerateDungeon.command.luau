-- Execute somente no Place separado da dungeon, em modo de edição.
require(game:GetService('ServerStorage'):WaitForChild('MedievalWorldgen'):WaitForChild('WorldGenerator')).GenerateDungeon()
