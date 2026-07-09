class_name JobPriorities

# Edit this array order to change game balance priorities globally
const HIERARCHY: Array[String] = [
	"sustenance",   # High Priority: Gathering food so the camp doesn't starve
	"builder",      # Mid Priority: Construction of ordered blueprints
	"woodcutter",   # Lower Priority: Raw extraction
	"forager"       # Production
]

static func get_priority_weight(job_type: String) -> int:
	var index = HIERARCHY.find(job_type)
	if index == -1:
		return 999 
	return index
