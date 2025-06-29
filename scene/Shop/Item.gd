extends Panel

@export var BuyNode:Button

func _process(delta):
	if Public.ListOfItemsBought.has(name):
		BuyNode.text = "Select"
	else:
		BuyNode.text = "Buy"
	
	if Public.SelectedItem == name:
		BuyNode.disabled = true
	else:
		BuyNode.disabled = false

func _on_buy_pressed():
	
	var cost:int = int($Cost.text)
	var moves:int = int($Moves.text)
	var reward:int = int($Reward.text)
	
	if (Public.SavedScore - cost) > 0:
		Public.SavedScore += -cost
		Public.ListOfItemsBought.append(name)
	
	if Public.ListOfItemsBought.has(name):
		Public.SelectedItem = name
		Public.PaintSteps = moves
		Public.PaintReward = reward
