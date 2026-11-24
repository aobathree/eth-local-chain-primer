# 準備: 道具をそろえる

鋳造所の門をくぐる前に、道具をそろえます。ここは 5 分ほどで終わります。

## 要るもの

- **Foundry**（`anvil`、`forge`、`cast`、`chisel`）。Ethereum のプログラムを作るための、道具のセットです（[用語集](glossary.md#foundryファウンドリー)）。入れ方は [公式の手順](https://getfoundry.sh/) にあります。この演習は 1.8.3 で確かめました。
- **Python 3**。`helpers.sh` が、結果を読みやすく並べるのに使います（標準ライブラリだけ）。
- macOS か Linux のターミナル（`bash` か `zsh`）。確かめたのは macOS の `zsh` です。

Foundry を入れるときは、ターミナルにコマンドを 1 行貼る形が案内されています。貼る前に、開いているページが公式のサイト（`getfoundry.sh`）であることを確かめてください。

入っているかどうかは、こう確かめます。

```bash
anvil --version
```

`anvil Version: 1.8.3` のように、版が出れば大丈夫です。

## このリポジトリを手元に置く

```bash
git clone https://github.com/aobathree/eth-local-chain-primer.git
```

中に入っているのは、これだけです。

| ファイル | 鋳造所でいうと | 中身 |
|---|---|---|
| `src/Counter.sol` | これから鍛える、鉄のかたまり | Solidity で書いた、数を 1 つ覚えるだけのプログラム |
| `foundry.toml` | 炉の設定 | forge の設定（Solidity の版は 0.8.20） |
| `helpers.sh` | 見習いの手もとの道具 | つなぎ先を決める。第 3 話で使う `show_pool` と `show_block` を用意する |

## ターミナルのタブを 2 つ開く

鋳造所では、2 つの場所を使います。

| タブ | 役目 | 鋳造所でいうと |
|---|---|---|
| タブ 1 | anvil を動かしたままにする | 金床を据える場所 |
| タブ 2 | コマンドを打つ | 自分が立つ場所 |

どちらのタブも、まだ何もしなくてかまいません。金床を据えるのは、[第 1 話](01_own_chain.md) の最初です。
