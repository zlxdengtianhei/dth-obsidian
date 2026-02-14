BERT及相关的架构是只为编码器，T5等为解码器，结合起来才能够完成完整的功能

#### Bag of Words
早期non transformer，如何表征语言来实现预言这个非结构化的内容的分析 
在tokenize之后，检查tokenize之后的结果中的词汇分别出现了几次，进行编码。
   也就是词汇表中的词在句子中出现了多少次，来衡量句子之间的相似性

#### Word2Vec
上面的方法只将句子看作词汇的组合，没有语义的部分。
本方法会通过神经网络，给定一组初始化向量，模型通过神经网络训练判断一个词与其他词在一句话中是否可能成为邻居。学习语义信息，并将这些信息作为embedding存储在向量中。
向量的各个维度表示了不同语义，用-1 - 1来衡量相关度（各维度具体表示什么是学出来的，不知道具体表示什么）
有时候tokenizer会拆分一个词，将他们的embedding取平均值，就是这个词的embedding，句子也是

#### RNN
encoder: Representing Language 通过嵌入来捕捉序列中的特征
decoder: 使用这些嵌入来生成目标语言

使用自回归的方式，模型输出一个token后，再输入这个token到序列中，生成下一个token 

这个embedding是整个句子生成一个，所以会很难表示长语句

#### attention
能够让模型聚焦于最有关的部分，输入与输出的token之间，如果相似度越高，attention得到的分数就会更高。

让encoder先使用W2V的方式进行embedding生成，并且也对词语间的hidden states(来自RNN隐藏层生成的内部因子，包含先前的词语信息)，decoder使用attention机制查看所有的embedding然后产生输出

#### tokenizer
input转为tokens，然后tokens对应一个数字，这个对应数字的过程也是embedding。此embedding为静态，生成结果时，也可以作为输出（即为输出那个embedding数字，也叫token id）。
数字还会对应一个向量，这个向量就是这个词的语义信息，这个整个的向量，就是输入嵌入层（input embedding layer)。他是一个由所有词对应的向量组成的矩阵，也是神经网络的一个层，因为它里面的数据是可学习的，同时输入嵌入层，输出嵌入层，一般是共享的矩阵，用于找到输出的词。
使用subword来进行tokenize，如果遇到未见过的词，可以依然用subword来代表，这时候会在token的前面加上##，作为前序还有token的表示

对于bert-base-cased, 会以\[cls]作为开头，然后\[sep]作为结尾（如果是生成式，则可能没有这些东西）

如果词汇表越大，每个token对应需要的嵌入向量计算量就更大，重点在于输出预测层，也就是语言模型头，负责预测下一个词元，具体在 [[Language Head]]

#### 架构概述
一个分词器有词表大小为50000，则在模型中，每个token都关联对应了一个embedding，即模型有50000个向量来表征这些token
在语言模型的最终端（Language Head），将会获得分词器定义的所有初始令牌（所有token id和token），对每个token，都会有一个概率评分，根据评分，可以选出下一个生成的词语（可以直接选概率最高，或者也可以通过几个词一起选，叫top-p），根据同一个prompt生成不同答案的机制也与decoder strategy有关，尤其是temperate>0时。

优于RNN的点在于可以并行处理输入。想象为多个通道流经Transformer stack，这个通道数的多少也就是上下文的长度。

生成答案时，先将输入的所有token完成处理，然后循环，对后续生成的每个token，与输入一起再次输入transformer，是一个循环过程。这个过程中可以cache kv

#### transformers
![[Pasted image 20251005112608.png]]
Transformer block1会生成与输入维度相同的向量。

每个block都是由自注意力机制块以及前馈神经网络组成（Self-attention, Feed Forward Neural Network, FFN)。

FFN对应的intuition是存储了信息和关于下一个词元的统计规律，基本代表了模型掌握的知识存储。[[FFN]]
![[Pasted image 20251005114021.png]]

自注意力机制让模型能够注意到先前token的信息，并将上下文信息融入到当前token的理解中。例如下面这个就可以让模型知道it指代的是什么。
![[Pasted image 20251005114145.png]]
自注意力机制
首先计算当前句子中的token与目前正在生成的token的相关度，
然后再将相关信息添加到当前表征中。

#### Self Attention
自注意力机制发生在称为注意力头的结构中。
![[Pasted image 20251005121019.png]]
使用projection矩阵，来计算出q, k, v矩阵，他们分别是由之前的token和当前token的信息组成

![[Pasted image 20251005121252.png]]
先前token相关度的计算如上，使用当前的token的queries乘整个key

![[Pasted image 20251005121429.png]]
得到与先前token有关信息的整合，使用刚才得到的score，乘value。[[Self-Attention]]

实际上是有多个attention head共同操作的，有的时候是全部使用不同的kv矩阵，有些使用相同的，然后还有grouped-query attention机制，使用比head数更少一点的kv矩阵。
![[Pasted image 20251005123411.png]]
![[Pasted image 20251005123542.png]]
稀疏注意力机制
以及ring attention环形注意力
![[Pasted image 20251005124943.png]]

