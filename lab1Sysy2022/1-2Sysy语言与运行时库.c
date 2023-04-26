const int N = 10;
int prices[N]; 

// 请完成函数maxProfit(),其输入为股价数组，输出为可获得的最大利润 
int maxProfit(int prices[]){
    // ----------  开始
    int minPrice = prices[0];
    int maxProfit = 0;
    int i=1;
    while(i<N){
        if (maxProfit < prices[i] - minPrice) {
            maxProfit = prices[i] - minPrice;
        }
        if (minPrice > prices[i]) {
            minPrice = prices[i];
        }
        i = i + 1;
    }
    return maxProfit;



    // ----------- 结束
}

// main()接收连续N个交易日的股价输入并存入数组prices[],
// 接着调用maxProfit()求可能的最大利润，然后输出该值，并换行。
int main(){
    // 股价数组的输入：
    int t = 0;
    while (t<N) {
        prices[t] = getint();
        t=t+1;
    }

    int best = maxProfit(prices);
    //结果输出：
    putint(best);
    putch(10);
   return 1;
}
