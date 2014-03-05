
{-@ LIQUID "--no-termination" @-}

module Foo where

data RBTree a = Leaf 
              | Node Col !BlackHeight !(RBTree a) a !(RBTree a)
              deriving (Show)

type Col = Int

-- data Color = B -- ^ Black
--            | R -- ^ Red
--            deriving (Eq,Show)


type BlackHeight = Int



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


-- delete :: Ord a => a -> RBTree a -> RBTree a
-- delete x t = turnB' s
--   where
--     (s,_) = delete' x t
-- 
-- delete' :: Ord a => a -> RBTree a -> RBTreeBDel a
-- delete' _ Leaf = (Leaf, False)
-- delete' x (Node c h l y r) = case compare x y of
--     LT -> let (l',d) = delete' x l
--               t = Node c h l' y r
--           in if d then unbalancedR c (h-1) l' y r else (t, False)
--     GT -> let (r',d) = delete' x r
--               t = Node c h l y r'
--           in if d then unbalancedL c (h-1) l y r' else (t, False)
--     EQ -> case r of
--         Leaf -> if c == B then blackify l else (l, False)
--         _ -> let ((r',d),m) = deleteMin' r
--                  t = Node c h l m r'
--              in if d then unbalancedL c (h-1) l m r' else (t, False)


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

{-@ insert :: (Ord a) => a -> RBT a -> RBT a @-}
insert :: Ord a => a -> RBTree a -> RBTree a
insert kx t = turnB (insert' kx t)

{-@ turnB :: ARBT a -> RBT a @-}
turnB :: RBTree a -> RBTree a
turnB Leaf           = error "turnB"
turnB (Node _ h l x r) = Node 1 h l x r

{-@ insert' :: (Ord a) => a -> t:(RBT a) -> {v:ARBT a | (isRB v)} @-}

-- {v: ARBT a | (((col t) /= 0) => (isRB v))} @-}
insert' :: Ord a => a -> RBTree a -> RBTree a
insert' kx Leaf = Node 0 1 Leaf kx Leaf
insert' kx s@(Node 1 h l x r) = case compare kx x of
    LT -> l -- balanceL' h (insert' kx l) x r
    -- GT -> balanceR' h l x (insert' kx r)
--    EQ -> s
-- insert' kx s@(Node 0 h l x r) = case compare kx x of
--    LT -> Node 0 h (insert' kx l) x r
--    GT -> Node 0 h l x (insert' kx r)
--     EQ -> s

{-@ balanceL' :: Int -> ARBT a -> a -> RBT a -> RBT a @-}
balanceL' :: BlackHeight -> RBTree a -> a -> RBTree a -> RBTree a
balanceL' h (Node 0 _ (Node 0 _ a x b) y c) z d =
   Node 0 (h+1) (Node 1 h a x b) y (Node 1 h c z d)
balanceL' h (Node 0 _ a x (Node 0 _ b y c)) z d =
   Node 0 (h+1) (Node 1 h a x b) y (Node 1 h c z d)
balanceL' h l x r =  Node 1 h l x r

{-@ balanceR' :: Int -> RBT a -> a -> ARBT a -> RBT a @-}
balanceR' :: BlackHeight -> RBTree a -> a -> RBTree a -> RBTree a
balanceR' h a x (Node 0 _ b y (Node 0 _ c z d)) =
    Node 0 (h+1) (Node 1 h a x b) y (Node 1 h c z d)
balanceR' h a x (Node 0 _ (Node 0 _ b y c) z d) =
    Node 0 (h+1) (Node 1 h a x b) y (Node 1 h c z d)
balanceR' h l x r = Node 1 h l x r

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

{-@ type RBT a  = {v: (RBTree a) | (isRB v)}  @-}

{-@ type ARBT a = {v: (RBTree a) | ((isARB v) && (((col v) = 1) => (isRB v)))} @-}

{-@ measure isRB           :: RBTree a -> Prop
    isRB (Leaf)            = true
    isRB (Node c h l x r)  = ((isRB l) && (isRB r) && ((c == 0) => ((col l) /= 0) && ((col r) /= 0)))
  @-}

{-@ invariant {v: RBTree a | (((col v) = 0) || ((col v) = 1))} @-}

-- isARB v => (c = R => (col l = R || col r = R))
{-@ measure isARB          :: (RBTree a) -> Prop
    isARB (Leaf)           = false 
    isARB (Node c h l x r) = ((isRB l) && (isRB r))
  @-}

{-@ measure col :: RBTree a -> Col
    col (Node c h l x r) = c
    col (Leaf)           = 2
  @-}
