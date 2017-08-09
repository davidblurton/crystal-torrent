def url_encode(digest)
  digest.map {|d| d.chr.ascii? ? URI.escape(d.chr.to_s) : "%#{d.to_s(16)}"}.join
end

def build_tracker_url(endpoint : String, info_hash : StaticArray(UInt8, 20), peer_id : String, length : Int32)
  url = URI.parse(endpoint)
	query = {
    "info_hash" => "f%60%21%95%EE%24%B6%15M%CB%EBLP%C7%B0%D11%5C%868",
    "peer_id" => peer_id,
    "port" => "6881",
    "compact" => "1",
    "downloaded" => "0",
    "event" => "started",
    "uploaded" => "0",
    "left" => length.to_s,
  }
	url.query = query.map{ |key, value|
    key + "="	+ value
    }.join('&')
  url.to_s
end
