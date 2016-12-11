![](https://bytebucket.org/LUXOPHIA/nablafield2d/raw/10816610ff5dbfc6706493203ec192b73f15f6e1/--------/_SCREENSHOT/NablaField2D.png)

# ﻿NablaField2D #
ポテンシャル分布からベクトル場を生成する方法。

`LUX.Lattice.T2.D1`ユニットの`TSingleGridMap2T`クラスは、`Grid[ X, Y ]`プロパティを持つ単純な2次元配列クラスですが、それらを 3次[B-Spline関数](https://www.wikiwand.com/ja/B-%E3%82%B9%E3%83%97%E3%83%A9%E3%82%A4%E3%83%B3%E6%9B%B2%E7%B7%9A) で補間しながら偏微分し、[ナブラ（∇）](https://www.wikiwand.com/ja/%E3%83%8A%E3%83%96%E3%83%A9) を計算する機能を有します。特に今回は スカラー値(Single型) のフィールドなので、[勾配（gradient）](https://www.wikiwand.com/ja/勾配_(ベクトル解析)) とも呼びます。

簡単に言えば、地形の起伏を定義した上で、任意の地点での最大傾斜方向を算出できるということ。つまりスカラー値のポテンシャルマップを作るだけで、自動的にベクトル場を生成することができます。

具体的には、マップの X, Y 方向へそれぞれ偏微分して、その微分値を X, Y とするベクトルを作ればいいだけ。

![](https://wikimedia.org/api/rest_v1/media/math/render/svg/1cdaf2f58e2eea132b68d3e232a34445ba723e5c)

しかも今回は、対象とするポテンシャル自体が B-Spline関数の和 として補間されているので、どんなに複雑な起伏であったとしても、B-Spline関数 の **導関数の和** を計算するだけで微分値が得られます。

しかし今回は、将来的に様々な補間関数へ対応することを視野に、わざわざ手作業で導関数を求めずに微分する手法「[自動微分](https://www.wikiwand.com/ja/%E8%87%AA%E5%8B%95%E5%BE%AE%E5%88%86)」を採用します。

その方補は至って簡単。
数学関数内で使用している実数型変数を、LUX.D1 ユニットにある TdSingle/Double レコードで置換して下さい。
どんなに複雑な関数だろうと、それだけで微分が可能となります。

```
function Func( X:Doubel ) :Double;
begin
     Result := X * X + X + 2;
end;
～
var
   A, B :Double;
begin
     A := 2;
     B := Func( A );
     // B = 関数値
end;
```
**↓**
```
function Func( X:TdDoubel ) :TdDouble;
begin
     Result := X * X + X + 2;
end;
～
var
   A, B :TdDouble;
begin
     A := TdDouble.Create( 2, 1 );
     B := Func( A );
     // B.o = 関数値
     // B.d = 微分値
end;
```


![](https://bytebucket.org/LUXOPHIA/nablafield2d/raw/10816610ff5dbfc6706493203ec192b73f15f6e1/--------/_SCREENSHOT/NablaField2D-OPTIMIZE.png)