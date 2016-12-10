![](https://bytebucket.org/LUXOPHIA/nablafield2d/raw/10816610ff5dbfc6706493203ec192b73f15f6e1/--------/_SCREENSHOT/NablaField2D.png)

# ﻿NablaField2D #
ポテンシャル分布からベクトル場を生成する方法。

`LUX.Lattice.T2.D1`ユニットの`TSingleGridMap2T`クラスは、`Grid[ X, Y ]`プロパティを持つ単純な2次元配列クラスですが、それらを 3次B-Spline関数 で補間しながら偏微分し、[ナブラ（∇）](https://www.wikiwand.com/ja/%E3%83%8A%E3%83%96%E3%83%A9) を計算する機能を有します。特に今回は スカラー値(Single型) のフィールドなので、[勾配（gradient）](https://www.wikiwand.com/ja/勾配_(ベクトル解析)) とも呼びます。

簡単に言えば、地形の起伏（ポテンシャル）を定義した上で、任意の地点での最大傾斜方向（ベクトル）を算出できるということ。スカラー値のマップを作るだけで、自動的にベクトル場を生成することができます。

※ ごめんなさい、まだ執筆中･･･

![](https://bytebucket.org/LUXOPHIA/nablafield2d/raw/10816610ff5dbfc6706493203ec192b73f15f6e1/--------/_SCREENSHOT/NablaField2D-OPTIMIZE.png)