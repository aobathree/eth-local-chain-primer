# 3. mempool と、ブロックの中の順番

[演習 2](02_deploy.md) の続きです。anvil は動かしたまま進めます。`C` には、デプロイした Counter のアドレスが入っていて、`number` は 42 です。

2 人が同じコントラクトに、ちがう値を書きこみます。あとから実行されたほうの値が残るので、**最後に残った値を見れば、順番が分かります**。

## 3-1. ブロックを勝手に作らないようにする

```bash
cast rpc evm_setAutomine false
```

```bash
cast block-number
```

出るはずの結果: `null`、`6`（ここまで手順のとおりに進めた場合）。

これで、取引を送っても、ブロックはできません。このときのブロック番号を覚えておきます。

## 3-2. 手数料の安い取引を先に、高い取引をあとに送る

```bash
cast send --async --unlocked --from $A --gas-price 2gwei $C "setNumber(uint256)" 111
```

```bash
cast send --async --unlocked --from $B --gas-price 5gwei $C "setNumber(uint256)" 222
```

- A は 111 を、安い手数料（2 gwei）で、**先に**送ります。
- B は 222 を、高い手数料（5 gwei）で、**あとに**送ります。
- `--async` は、「ブロックに入るのを待たずに戻る」という指定です。これがないと、ブロックができるまで、コマンドが止まったままになります。

それぞれ、取引のハッシュ（`0x…`）が 1 行出ます。

## 3-3. 待合室をのぞく

```bash
cast block-number
```

```bash
cast call $C "number()(uint256)"
```

```bash
show_pool
```

出るはずの結果: ブロック番号は `6` のまま。値は `42` のまま。待合室には 2 本あります。

```
pending 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 nonce 0 5.0 gwei setNumber 222
pending 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 nonce 4 2.0 gwei setNumber 111
```

取引は送られましたが、まだ実行されていません。**これが mempool です。**

ここで中身が全部見えるのは、自分がノードの持ち主だからです。Ethereum のような公開のチェーンでは、公開の mempool に入った取引は、ノードを動かしている人ならだれでも見られます。他人の取引を見てから、自分の取引を前に入れる、ということが起きるのは、このためです。

## 3-4. ブロックを掘る

```bash
cast rpc evm_mine
```

```bash
show_block
```

```bash
cast call $C "number()(uint256)"
```

出るはずの結果:

```
block 7
0 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 5.0 gwei setNumber 222
1 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 2.0 gwei setNumber 111
```

値は `111`。

- あとから送った B（手数料が高い）が、先に実行されました。
- A の 111 があとから上書きしたので、111 が残りました。
- **送った順ではなく、手数料の順で実行されます。**

## 3-5. 手数料を入れかえて、もう一度

```bash
cast send --async --unlocked --from $A --gas-price 5gwei $C "setNumber(uint256)" 111
```

```bash
cast send --async --unlocked --from $B --gas-price 2gwei $C "setNumber(uint256)" 222
```

```bash
cast rpc evm_mine
```

```bash
show_block
```

```bash
cast call $C "number()(uint256)"
```

出るはずの結果:

```
block 8
0 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 5.0 gwei setNumber 111
1 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 2.0 gwei setNumber 222
```

こんどは A が先、B があと。値は `222`。

同じ 2 本の取引でも、手数料を変えるだけで、結果が変わります。

## 3-6. 元に戻す

```bash
cast rpc evm_setAutomine true
```

## 演習 3 で分かること

- mempool は、送られたがまだブロックに入っていない取引の、待合室です。
- 取引は、ブロックに入ったときに、並んだ順に実行されます。順番がちがえば、結果もちがいます。
- `--order fees` では、順番は手数料で決まります。同じ機会をねらう人が何人もいるとき、順番は手数料の入札で争われます。
- この演習では「あとのほうが残る」形でした。裁定や清算では逆で、**先に実行されたほうが取ります**（あとのほうは、もう機会がなくなっています）。だから、高い手数料を出す意味があります。

## 余力があれば: 並べ方の決まりを変える

順番を決めているのは、チェーンを運営する側です。anvil では、`--order fifo` で「届いた順」に変えられます。

タブ 1 の anvil を Ctrl+C で止めて、こう始め直します。

```bash
anvil --port 8546 --order fifo
```

状態は消えているので、演習 1 と 2 をもう一度進めてから（ブロック番号とアドレスを同じにするため）、3-1 から 3-5 をやり直します。

確かめた結果:

| | `--order fees` | `--order fifo` |
|---|---|---|
| 3-4（A が 2 gwei で先、B が 5 gwei であと） | B が先に実行、値は `111` | A が先に実行、値は `222` |
| 3-5（A が 5 gwei で先、B が 2 gwei であと） | A が先に実行、値は `222` | A が先に実行、値は `222` |

`fifo` では、手数料に関係なく、先に送った A が先に実行されます。**同じ取引でも、運営する側が並べ方の決まりを変えると、結果が変わります。**

## 確かめていないこと

- 本物の Ethereum では、ブロックを作る人は、手数料の順に並べるとは限りません（順番そのものが売り買いされています）。ここで見たのは、anvil の 2 つの決まりだけです。
- 手数料は `--gas-price` で指定しました。Ethereum のいまの手数料のしくみ（base fee と priority fee）で指定したときの並び方は、比べていません。
