Hi everyone, we are Group 1, and our project is _Stitching LLMs Across Multiple Servers_. Today, the demonstration will be presented by me, Lexuan, Yuxuan, and Pelle. First, I will demonstrate running our system, which combines RouterLLM and StitchLLM, on a single server to handle a single query as well as a batch of queries.

---
While we wait for the results, let me introduce the models we used. We chose Qwen 2.5 7B as the bottom model and Qwen 1.5B as the top model. You can see their overall architecture and dimension settings in the terminal. bottom hidden size of XXXX dimensions to the top hidden size of XXXX dimensions.  


---

Both models consist of 28 decoder layers. Our stitch layer operates at the selected index—index 20 for the strong model and index 15 for the weak model.


-----
Here, you can see th e judgment made by the router for this question. It chose the strong model to answer the question, and the strong model’s response is displayed here.

-----
Now we can run a response for a batch of questions. 




----


Large language models (LLMs) have become the core of modern natural language processing, achieving high performance across a wide range of tasks. However, the inference process requires significant memory and computational resources. A practical issue is that most LLM series are released in only a few fixed sizes (e.g., Llama 3 provides 8B and 70B variants). The result is a lack of flexibility in resource and performance optimization, leading to what we call the "granularity problem": users must either settle for a small model with poor performance or deploy an excessively large model that is costly and inefficient.

To address the limitations of model selection, we implemented a system that combines StitchLLM and RouterLLM. Given an input query, the router selects either a strong model or a weak model. At the same time, by using stitch layers to combine two pre-trained models, a stitched model can merge the lower layers of a larger model with the upper layers of a smaller model. This creates an intermediate-capacity model that balances performance and cost. By adjusting the stitching index, the system achieves a setup where one strong model and one weak model work together to achieve the best possible results within a limited cost.

The stitch layer is a linear layer that processes the different hidden sizes of the bottom and top models. It projects the bottom hidden size of XXXX dimensions to the top hidden size of XXXX dimensions. This projection have to  make some loss of features. However, our goal is to approximate the capacity of a larger model (the bottom model) as much as possible within limited resources. Therefore, a certain amount of information loss is acceptable.


Since the combination of Qwen 2.5 7B and Qwen 1.5B nearly exhausts all GPU memory, there is no extra space left to store the KV cache. If we were to choose smaller models, there would be fewer stitching index options, and we also lack the time for additional training and testing. As a result, during inference with StitchLLM, we did not implement prefill optimization. This means that for every new token generated, all keys (K) and values (V) must be recalculated. As the number of tokens increases, the time grows quadratically. To save time, I limited the maximum output length to 128 tokens, but it is still a bit slow.


---
Here, you can see the TTFT (Time to First Token). Excluding the initial model loading time, TTFT is positively correlated with the prompt length. You can see the linear regression model in this graph, showing that the strong model takes longer to generate the first token. This proves that model capability and resource usage involve a trade-off.