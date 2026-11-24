# 2. コントラクトをデプロイする

[演習 1](01_own_chain.md) の続きです。anvil は動かしたまま進めます。

使うのは [../src/Counter.sol](../src/Counter.sol) です。数を 1 つ覚えるだけのコントラクトです。

```solidity
contract Counter {
    uint256 public number;
    function setNumber(uint256 newNumber) public { number = newNumber; }
    function increment() public { number++; }
}
```

## 2-1. 置く前は、そこに何もない

コントラクトが置かれるアドレスは、「送る人」と「その人の何本めの取引か（nonce）」で、先に決まります。

```bash
cast compute-address $A --nonce $(cast nonce $A)
```

出るはずの結果: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`（演習 1 を手順のとおりに進めた場合。このとき A の nonce は `1` です）。

```bash
C=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
```

```bash
cast code $C
```

出るはずの結果: `0x`。プログラムは何も置かれていません。

## 2-2. デプロイする

```bash
forge create src/Counter.sol:Counter --unlocked --from $A --broadcast --rpc-url $ETH_RPC_URL
```

出るはずの結果（最初の 1 回は、コンパイラーの取得とコンパイルの表示が先に出ます）:

```
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Transaction hash: 0x…
```

`Deployed to` が、先に計算したアドレスと同じになります。ちがう値が出たら、`C` をその値に入れ直してください。

## 2-3. デプロイの正体を見る

```bash
cast code $C
```

`0x6080604052…` で始まる長い文字が出ます。これが、チェーンの上に置かれたプログラム本体です。

`Transaction hash` の値を使って、デプロイの取引そのものを見ます。

```bash
cast tx <Transaction hash の値>
```

```bash
cast receipt <Transaction hash の値>
```

見るところ:

- `cast tx` の `to` が空です。**宛先のない取引**が、デプロイです。
- `input` に、プログラムが入っています。
- 領収書（`cast receipt`）の `contractAddress` に、置かれたアドレスが書かれます。

## 2-4. 読む・書く

```bash
cast call $C "number()(uint256)"
```

```bash
cast send --unlocked --from $A $C "setNumber(uint256)" 42
```

```bash
cast call $C "number()(uint256)"
```

```bash
cast storage $C 0
```

出るはずの結果: `0`、送信のあと `42`、最後は `0x000000000000000000000000000000000000000000000000000000000000002a`（16 進数の 2a は 42）。

- `cast call` は読むだけです。取引にならず、手数料もかかりません。
- `cast send` は取引です。ブロックに入って、状態が変わります。
- `cast storage` は、コントラクトの記憶領域の 0 番めを直接のぞきます。`number` はそこに入っています。

## 2-5. 運営は、記憶領域を直接書きかえられる

```bash
cast rpc anvil_setStorageAt $C 0x0 0x00000000000000000000000000000000000000000000000000000000000003e7
```

```bash
cast call $C "number()(uint256)"
```

出るはずの結果: `true`、`999`（16 進数の 3e7 は 999）。

`setNumber` を呼んでいないのに、値が変わります。手元のチェーンでの試験では、この方法で「値段を知らせるコントラクト（オラクル）に、好きな値段を書きこむ」といったことができます。

演習 3 のために、値を 42 に戻しておきます。

```bash
cast send --unlocked --from $A $C "setNumber(uint256)" 42
```

## 演習 2 で分かること

- デプロイは、「宛先のない取引にプログラムを入れて送ること」です。
- 空のチェーンには、トークンも取引所もありません。使うものは、だれかが先に全部置かなければなりません。手元のチェーンで DEX やレンディングを試すには、それらのコントラクトを、依存の順に自分でデプロイして、プールや設定まで作る必要があります。
- 置いたプログラムの計算は、本物と同じです。中の値（残高、値段、流動性）は、運営する側が決めたものです。

## 補足: すでにあるチェーンを写す方法

anvil には、本物のチェーンのある時点の状態を写して始める方法（`--fork-url`）もあります。この場合は、すでに置かれているコントラクトをそのまま使えます。この演習では扱っていません（試していません）。

次は [演習 3](03_mempool.md) です。anvil は止めずに、そのまま進みます。
