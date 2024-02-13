extends Node

func _ready():
	fetch("", ["Header: value"], 0, "handle_response")

func fetch(url: String = "https://www.duckduckgo.com", headers: Array = [], method = HTTPClient.METHOD_GET, callback: String = "AAAAAA", body = null):
	if url == null or url == "":
		return null
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, callback)
	http_request.connect("request_completed", self, "deletechild", [http_request])
	var req
	if body != null:
		req = http_request.request(url, headers, true, method, body)
	else:
		req = http_request.request(url, headers, true, method)
	if req != HTTPClient.RESPONSE_OK:
		return "error"
		
func handle_response(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response)
		
func deletechild(_a, _b, _c, _d, child):
	child.queue_free()
