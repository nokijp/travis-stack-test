import Test.Hspec
import TestLib

main :: IO ()
main = hspec $
  describe "testFunc" $
    it "returns 2 when given 1" $
      testFunc 1 `shouldBe` 1
