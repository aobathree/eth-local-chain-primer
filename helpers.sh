# 演習用の小さな道具。使い方: source helpers.sh
# どれも読むだけで、チェーンの状態は変えない。

export ETH_RPC_URL=http://127.0.0.1:8546

# 待合室（mempool）の中身を 1 行ずつ出す
show_pool() {
  cast rpc txpool_content | python3 -c '
import json, sys
d = json.load(sys.stdin)
rows = [(k, a, n, t) for k in d for a in d[k] for n, t in d[k][a].items()]
if not rows:
    print("(待合室は空)")
for k, a, n, t in rows:
    fee = int(t.get("maxFeePerGas") or t["gasPrice"], 16) / 1e9
    print(k, a, "nonce", n, fee, "gwei", "setNumber", int(t["input"][-8:], 16))
'
}

# いちばん新しいブロックの中の取引を、実行された順に出す
show_block() {
  cast block latest --json --full | python3 -c '
import json, sys
b = json.load(sys.stdin)["data"]
print("block", int(b["number"], 16))
for t in b["transactions"]:
    fee = int(t.get("maxFeePerGas") or t["gasPrice"], 16) / 1e9
    print(int(t["transactionIndex"], 16), t["from"], fee, "gwei", "setNumber", int(t["input"][-8:], 16))
'
}
