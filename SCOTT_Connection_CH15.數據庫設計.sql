--============================================================================--
--                                                                            --
/* ※數據庫設計-概念模型                                                      */
--                                                                            --
--============================================================================--
-- 數據庫項目開基本步驟:
-- 第一步:獲取需求
-- 第二步:需求分析
-- 第三步:軟件設計
-- 第四步:程序編碼
-- 第五步:軟件測試
-- 第六步:運行回護
-- 在軟件設計階段除了數據庫之外，還會包含UI設計、介面設計、業務設計。

-- ➤E-R模型
-- 說明:概念模型式對訊息世界的建模，所以概念模型應該能夠方便、準確地表示出訊息
-- 世界中的常用概念，概念模型的表示方法很多，其中最為著名最為常用的是實體-聯繫
-- 方法(Entity-RelationshipApproach)。該方法使用E-R圖(E-R Diagram)來描述實現世
-- 界的概念模型，E-R方法也稱為E-R模型(Entity-Relation Model，或稱為實體關係模
-- 型)。
/*
---------------------------------------------------------------------
|No.|ER模型組成元素   |描述                                         |
---------------------------------------------------------------------
|1  |實體(Entity)     |用來描述顯示世界的實體，如:學生、員工、部門等|
---------------------------------------------------------------------
|2  |屬性(Attribute)  |用於描述實體的性質，如:名稱、年齡、性別等    |
---------------------------------------------------------------------
|3  |鍵(Key)          |用於描述實體集合之中每一個實體數據的唯一性， |
|   |                 |如:員工編號、部門編號、身份證號等            |
---------------------------------------------------------------------
|4  |聯繫(Relationshi)|用於描述兩個實體之間的聯繫，如:一對一關係、  |
|   |                 |一對多關係、多對多關係                       |
---------------------------------------------------------------------
*/


-- ➤E-R模型實例
-- 現在假設存在一個用戶購買商品的數據庫。
-- 題目要求:
-- ①網站可以進行用戶的註冊，用戶註冊時可以快速註冊或是完整註冊。快速註冊只需要
-- 填寫用戶名即密碼即可，而完整註冊需要填寫用戶名、密碼、信箱、真實姓名、性別等
-- 訊息。
-- ②每一個用戶可以有多個派送地址，每個用戶在下購買訂單時可以選擇相應的派送地址
-- 。
-- ③用戶可以直接購買多種商品，同時下訂單，每個訂單可以有訂單詳情，用於紀錄用戶
-- 所購買的商品訊息、數量等訊息。
-- ④用戶可以針對商品購買過的商品進行評論，同時為購買過的商品進行打分。

-- 題目分析:
-- 根據以上題目要求，此時可以給出如下個實體即屬性定義:
-- 用戶(用戶ID，密碼，註冊日期)
-- 用戶訊息(用戶ID，信箱，真實姓名，性別)
-- 用戶地址(地址ID，用戶ID，城市，區域，地址，電話，郵遞區號)
-- 商品(商品ID，商品名稱，單價)
-- 訂單(訂單ID，用戶ID，地址ID，總價，訂單日期)
-- 訂單詳情(訂單詳情ID，訂單ID，商品ID，數量)
-- 商品評論(評論ID，用戶ID，商品ID，評論內容，分數，評論日期)

-- 建立ER圖
-- 一對一關聯:用戶與用戶訊息(一個用戶只會存在一個用戶(詳細)訊息)
-- 一對多關聯:用戶與訂單(一個用戶可以同時下多個訂單)
-- 一對多關聯:訂單與訂單詳情(一個訂單會購買多件商品，每件商品有不同的購買數量)
-- 一對多關聯:商品與訂單詳情(一個商品可以同時被購買多次，在多個訂單詳情中會有
-- 紀錄)
-- 多對多關聯:商品評論(一個用戶可以評論多個商品，一個商品可以同時被多個用戶評論)
--============================================================================--
--                                                                            --
/* ※數據庫設計-數據庫正規化                                                  */
--                                                                            --
--============================================================================--
-- 說明:數據庫設計正規化是合理設計數據庫所需要滿足的相關規範，而合理的數據庫設計
-- ，可以利於數據庫的維護。按照規範設計的數據庫是簡潔的、結構清晰的、數據可以方
-- 便的進行增加(INSERT)、修改(UPDATE)、刪除(DELETE)操作，同時可以減少不需要的冗
-- 餘數據。

-- ➤第一正規化(1NF)
-- 第一正規化定義:數據表中的每個欄位都是不可再分原子數據項，不能是數組、集合等複
-- 合屬性，只能是數字(NUMBER)、字串(VARCHAR2)、日期時間(DATE、TIME、TIMESTAMP)
-- LOB(CLOB、BLOB)等基本數據類型。


-- ➤第二正規化(2NF)
-- 第二正規化定義:數據庫表中不存在非關鍵欄位對任意一候選關鍵欄位的部份函數依賴(
-- 部份函數依賴指的是存在組合關鍵字中的某些欄位決定非關鍵欄位的情況)，也即所有非
-- 關鍵欄位都完全依賴於任一組候選關鍵字。
-- 沒有包含在主鍵中的列必須完全依賴於主鍵，而不能只依賴於主鍵的一部分。


-- ➤第三正規化(3NF)
-- 在第二正規化的基礎上，數據表中如果不存在非關鍵欄位度任一候選關鍵欄位的傳遞函
-- 數依賴則符合第三正規化。所謂傳遞函數依賴，指的是如果存在"A->B->C"的決定關係，
-- 則C傳遞函數依賴於A。因此，滿足第三正規化的數據庫表應該不存在如下依賴關係:
-- 關鍵欄位->非關鍵欄位X->非關鍵欄位Y
-- 第三正規化實際上也就是一種一對多的體現，而在開發之中此類設計正規化使用也是最多的。


-- ➤鮑依斯-科得正規化(BCNF)
-- 在第三正規化的基礎上，消除欄位對任一候選關鍵欄位的傳遞函數依賴，則稱其為
-- 鮑依斯-科得正規化(簡稱BC正規化)。
--============================================================================--
--                                                                            --
/* ※數據庫設計-Sybase PowerDesigner設計工具                                  */
--                                                                            --
--============================================================================--
-- ➤概念模型
-- PowerDesigner設計工具建立概念模型


-- ➤物理模型
-- 由於PowerDesigner 15.1版本未支援Oralce 12c，所以建立Oracle 11g的物理模型
-- 即可。


-- ➤生成SQL文檔
-- 工具列->數據庫->Generate DataBase
-- 生成文檔後編輯內容:
-- ①雙引號改為單引號。
-- ②DROP TABLE 語句調整順序，先刪子表後刪父表。
-- ③將使用DDL增加的外鍵索引改為DML創建。













