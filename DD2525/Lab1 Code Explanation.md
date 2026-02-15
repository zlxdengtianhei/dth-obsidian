import lists (* 导入 lists 模块 *)
(* Assume toString is built-in or available *) (* 假设 toString 是内置函数或可用 *)

let fun server db = (* 定义服务器函数 server，参数 db 是一个存储 (profile, recallAgent, receiverPid) 元组的列表 *)
        let
            val _ = printString "Waiting for new requests..." (* 打印等待新请求的消息 *)
            (* Expecting ("NEWPROFILE", (profile, recallAgent, receiverPid)) *) (* 期望接收的消息格式为 ("NEWPROFILE", (profile, recallAgent, receiverPid)) *)
            val messagePayload = receive [ hn ("NEWPROFILE", payload) => payload ] (* 接收 "NEWPROFILE" 类型的消息，并将 payload 绑定到 messagePayload *)
            val (newProfile, newRecallAgent, newReceiverPid) = messagePayload (* 正确地从 messagePayload 中提取 profile, recallAgent 和 receiverPid *)
            val _ = printString "Received NEWPROFILE." (* 打印接收到 NEWPROFILE 消息的确认 *)
            val _ = printString "Profile data associated with NEWPROFILE message:" (* 打印 NEWPROFILE 消息关联的个人资料数据 *)
            val _ = printWithLabels newProfile (* 打印 profile 以供调试，带标签 *)

            (* Immediately declassify the profile and recall agent to avoid label pollution *) (* 立即解密 profile 和 recall agent 以避免标签污染 *)
            val (declassifiedProfile, declassifiedAgent) =
                let pini authority (* 开始一个 pini 块，指定 authority *)
                    val lowProfile = declassify(newProfile, authority, `{}`) (* 使用 authority 将 newProfile 解密到公共标签 `{}` *)
                    val lowAgent = declassify(newRecallAgent, authority, `{}`) (* 使用 authority 将 newRecallAgent 解密到公共标签 `{}` *)
                in
                    (lowProfile, lowAgent) (* 返回解密后的 profile 和 agent *)
                end
            val _ = printString "Declassified profile and agent to prevent security label pollution" (* 打印已解密 profile 和 agent 的消息 *)

            (* Step 1: Update the database with declassified versions and receiverPid *) (* 第一步：使用解密后的版本和 receiverPid 更新数据库 *)
            val updatedDb = (declassifiedProfile, declassifiedAgent, newReceiverPid) :: db (* 将新的 (解密后的 profile, 解密后的 agent, receiverPid) 添加到数据库列表 db 的头部 *)
            val _ = printString ("Database updated. New size: " ^ (toString (length updatedDb))) (* 打印数据库已更新以及新的大小 *)

            (* Step 2: Perform bidirectional matching logic *) (* 第二步：执行双向匹配逻辑 *)
            fun checkMatches existingRecords = (* 定义检查匹配的函数 checkMatches，参数 existingRecords 是数据库中的记录列表 *)
                case existingRecords of (* 对 existingRecords 进行模式匹配 *)
                    [] => () (* 如果列表为空，则不执行任何操作，结束递归 *)
                  | (existingProfile, existingRecallAgent, existingReceiverPid) :: rest => (* 如果列表不为空，解构出第一个记录和剩余列表 *)
                      let
                          val _ = printString "Checking match between profiles" (* 打印正在检查 profile 之间匹配的消息 *)

                          (* Test if new profile is interested in existing profile - USING NESTED PINI BLOCKS *) (* 测试新 profile 是否对现有 profile 感兴趣 - 使用嵌套的 PINI 块 *)
                          (* First PINI block to capture result from agent call *) (* 第一个 PINI 块，用于捕获 agent 调用的结果 *)
                          val tempNewInterestResult =
                              let pini authority (* 开始一个 pini 块 *)
                                  val result = declassifiedAgent existingProfile (* 调用解密后的 agent，传入现有的 profile *)
                              in
                                  result (* 返回 agent 调用的结果 *)
                              end

                          (* Second PINI block to clean up and declassify the result *) (* 第二个 PINI 块，用于清理和解密结果 *)
                          val newInterestResult =
                              let pini authority (* 开始一个 pini 块 *)
                                  val cleanResult = declassify(tempNewInterestResult, authority, `{}`) (* 将 agent 调用的结果解密到公共标签 *)
                              in
                                  cleanResult (* 返回解密后的结果 *)
                              end

                          val newInterested =
                              case newInterestResult of (* 对解密后的新兴趣结果进行模式匹配 *)
                                  (interested, _) => interested (* 提取结果元组中的第一个元素（布尔值，表示是否感兴趣） *)
                          val _ = printString "New profile interest check complete" (* 打印新 profile 兴趣检查完成的消息 *)

                          (* Test if existing profile is interested in new profile - USING NESTED PINI BLOCKS *) (* 测试现有 profile 是否对新 profile 感兴趣 - 使用嵌套的 PINI 块 *)
                          (* First PINI block to capture result from agent call *) (* 第一个 PINI 块，用于捕获 agent 调用的结果 *)
                          val tempExistingInterestResult =
                              let pini authority (* 开始一个 pini 块 *)
                                  val result = existingRecallAgent declassifiedProfile (* 调用现有的 recall agent，传入解密后的新 profile *)
                              in
                                  result (* 返回 agent 调用的结果 *)
                              end

                          (* Second PINI block to clean up and declassify the result *) (* 第二个 PINI 块，用于清理和解密结果 *)
                          val existingInterestResult =
                              let pini authority (* 开始一个 pini 块 *)
                                  val cleanResult = declassify(tempExistingInterestResult, authority, `{}`) (* 将 agent 调用的结果解密到公共标签 *)
                              in
                                  cleanResult (* 返回解密后的结果 *)
                              end

                          val existingInterested =
                              case existingInterestResult of (* 对解密后的现有兴趣结果进行模式匹配 *)
                                  (interested, _) => interested (* 提取结果元组中的第一个元素（布尔值，表示是否感兴趣） *)
                          val _ = printString "Existing profile interest check complete" (* 打印现有 profile 兴趣检查完成的消息 *)

                          (* If mutual interest, send match notifications *) (* 如果双方互相感兴趣，则发送匹配通知 *)
                          val _ = let pini authority (* 将整个 if 条件包装在 pini 块中 *)
                                      val _ = printString "Debug before if condition:" (* 打印 if 条件之前的调试信息 *)

                                      (* Declassify the matching results again *) (* 再次解密匹配结果 *)
                                      val cleanNewInterested = declassify(newInterested, authority, `{}`) (* 解密新 profile 的兴趣结果 *)
                                      val cleanExistingInterested = declassify(existingInterested, authority, `{}`) (* 解密现有 profile 的兴趣结果 *)

                                      val _ = if cleanNewInterested andalso cleanExistingInterested then (* 如果解密后的新兴趣和现有兴趣都为真 *)
                                                let
                                                    val _ = printString "Mutual interest detected!" (* 打印检测到相互兴趣的消息 *)

                                                    (* Send match notification to new profile - with explicit pini block *) (* 发送匹配通知给新 profile - 使用显式的 pini 块 *)
                                                    val _ = let pini authority (* 开始一个 pini 块 *)
                                                                (* Make sure to completely declassify the profile *) (* 确保完全解密 profile *)
                                                                val _ = printString "Preparing to send match notification to new node" (* 打印准备发送匹配通知给新节点的消息 *)

                                                                (* Extract and declassify each field individually *) (* 单独提取并解密每个字段 *)
                                                                val (levelStr, name, year, gender, interests) = existingProfile (* 从现有 profile 中提取字段 *)
                                                                val cleanLevelStr = declassify(levelStr, authority, `{}`) (* 解密 levelStr *)
                                                                val cleanName = declassify(name, authority, `{}`) (* 解密 name *)
                                                                val cleanYear = declassify(year, authority, `{}`) (* 解密 year *)
                                                                val cleanGender = declassify(gender, authority, `{}`) (* 解密 gender *)
                                                                val cleanInterests = declassify(interests, authority, `{}`) (* 解密 interests *)

                                                                (* Reconstruct profile with all clean fields *) (* 使用所有干净的字段重建 profile *)
                                                                val cleanExistingProfile = (cleanLevelStr, cleanName, cleanYear, cleanGender, cleanInterests) (* 创建包含所有解密字段的现有 profile 元组 *)

                                                                val _ = printString "Profile after deep declassification:" (* 打印深度解密后的 profile 信息 *)
                                                                val _ = printWithLabels cleanExistingProfile (* 打印解密后的现有 profile *)

                                                                (* Extract the recipient's node identifier and raise trust *) (* 提取接收者的节点标识符并提升信任 *)
                                                                val receiverNode = node(newReceiverPid) (* 获取新 profile 接收者的节点标识符 *)
                                                                val _ = printString ("Raising trust level for new profile node: " ^ receiverNode) (* 打印提升新 profile 节点信任级别的消息 *)
                                                                val _ = raiseTrust(receiverNode, authority, cleanLevelStr) (* 提升新 profile 接收者节点的信任级别到 cleanLevelStr *)
                                                                val _ = printString "Successfully raised trust level for new profile node" (* 打印成功提升新 profile 节点信任级别的消息 *)
                                                            in
                                                                send(newReceiverPid, ("NEWMATCH", cleanExistingProfile)); (* 向新 profile 的接收者发送 "NEWMATCH" 消息和解密后的现有 profile *)
                                                                printString "Notification sent to new profile" (* 打印已向新 profile 发送通知的消息 *)
                                                            end

                                                    (* Send match notification to existing profile - with explicit pini block *) (* 发送匹配通知给现有 profile - 使用显式的 pini 块 *)
                                                    val _ = let pini authority (* 开始一个 pini 块 *)
                                                                (* Make sure to completely declassify the profile *) (* 确保完全解密 profile *)
                                                                val _ = printString "Preparing to send match notification to existing node" (* 打印准备发送匹配通知给现有节点的消息 *)

                                                                (* Extract and declassify each field individually *) (* 单独提取并解密每个字段 *)
                                                                val (levelStr, name, year, gender, interests) = declassifiedProfile (* 从解密后的新 profile 中提取字段 *)
                                                                val cleanLevelStr = declassify(levelStr, authority, `{}`) (* 解密 levelStr *)
                                                                val cleanName = declassify(name, authority, `{}`) (* 解密 name *)
                                                                val cleanYear = declassify(year, authority, `{}`) (* 解密 year *)
                                                                val cleanGender = declassify(gender, authority, `{}`) (* 解密 gender *)
                                                                val cleanInterests = declassify(interests, authority, `{}`) (* 解密 interests *)

                                                                (* Reconstruct profile with all clean fields *) (* 使用所有干净的字段重建 profile *)
                                                                val cleanNewProfile = (cleanLevelStr, cleanName, cleanYear, cleanGender, cleanInterests) (* 创建包含所有解密字段的新 profile 元组 *)

                                                                val _ = printString "Profile after deep declassification:" (* 打印深度解密后的 profile 信息 *)
                                                                val _ = printWithLabels cleanNewProfile (* 打印解密后的新 profile *)

                                                                (* Extract the recipient's node identifier and raise trust *) (* 提取接收者的节点标识符并提升信任 *)
                                                                val receiverNode = node(existingReceiverPid) (* 获取现有 profile 接收者的节点标识符 *)
                                                                val _ = printString ("Raising trust level for existing profile node: " ^ receiverNode) (* 打印提升现有 profile 节点信任级别的消息 *)
                                                                val _ = raiseTrust(receiverNode, authority, cleanLevelStr) (* 提升现有 profile 接收者节点的信任级别到 cleanLevelStr *)
                                                                val _ = printString "Successfully raised trust level for existing profile node" (* 打印成功提升现有 profile 节点信任级别的消息 *)
                                                            in
                                                                send(existingReceiverPid, ("NEWMATCH", cleanNewProfile)); (* 向现有 profile 的接收者发送 "NEWMATCH" 消息和解密后的新 profile *)
                                                                printString "Notification sent to existing profile" (* 打印已向现有 profile 发送通知的消息 *)
                                                            end
                                                in
                                                    printString "Match processing complete" (* 打印匹配处理完成的消息 *)
                                                end
                                              else
                                                printString "No mutual interest" (* 如果没有相互兴趣，则打印此消息 *)

                                  in
                                      () (* pini 块结束，不返回任何值 *)
                                  end

                      in
                          (* Recursive call to check remaining records *) (* 递归调用以检查剩余的记录 *)
                          checkMatches rest (* 对列表的剩余部分调用 checkMatches *)
                      end

            (* Check matches with all existing profiles except the newest one *) (* 检查与除最新 profile 之外的所有现有 profile 的匹配 *)
            val _ = printString "Starting matching process..." (* 打印开始匹配过程的消息 *)
            val _ = checkMatches db (* 调用 checkMatches 函数，传入当前数据库（不包括最新的） *)
            val _ = printString "Matching process completed" (* 打印匹配过程完成的消息 *)

         in
              (* Recurse with updated database *) (* 使用更新后的数据库进行递归 *)
              server updatedDb (* 递归调用 server 函数，传入包含新 profile 的更新数据库 *)
         end

    fun main () = (* 定义主函数 main *)
        let val thisNode = node (self ()) (* 获取当前节点的标识符 *)
            val _ = printString ("Running node with identifier: " ^ thisNode) (* 打印当前节点的标识符 *)
            val serverId = spawn (fn () => server []) (* 创建一个新的进程来运行 server 函数，初始数据库为空列表 [] *)
            val _ = register ("datingServer", serverId, authority) (* 将新创建的服务器进程注册为 "datingServer"，使用 authority *)

        in  (* TODO: Feel free to comment out the next line *) (* TODO: 在开发解决方案和处理一些自定义客户端时，可以随意注释掉下一行 *)
                     (* while you develop your solution and work on a few *)
                     (* custom clients;  *)
            send (whereis ("@dispatcher", "dispatcher"), ("DISPATCH", thisNode)) (* 向名为 "dispatcher" 的节点（位于 "@dispatcher"）发送 "DISPATCH" 消息，包含当前节点的标识符 *)
        end
in
    main () (* 调用主函数 main *)
end


-----
(\* Dating Client - Arya Stark *) (* 约会客户端 - Arya Stark *)

import lists (\* Import lists library for list operations *) (* 导入 lists 库以进行列表操作 *)

let
  (\* Define a function to receive match notifications *) (* 定义一个接收匹配通知的函数 \*)
  fun receiveMatches () =
    let
      val _ = printString "Arya is waiting for matches..." (\* 打印等待消息 \*)
    in
      receive \[ (\* 设置消息处理器 \*)
        (\* Handle new match notifications \*) (\* 处理新的匹配通知 \*)
        hn ("NEWMATCH", profile) => (* 当收到类型为 "NEWMATCH" 的消息时 *)
          let
            (* Extract name from matched profile tuple - back to 5-tuple format *) (* 从匹配的 profile 元组中提取信息 - 回到 5 元组格式 *)
            val (levelStr, matchedName, matchedYear, matchedGender, matchedInterests) = profile (* 解构收到的 profile 元组 *)
            val _ = printString "Arya received a new match notification!" (* 打印收到新匹配通知的消息 *)
            val _ = printString ("Arya matched with: " ^ matchedName) (* 打印匹配对象的名字 *)
            val _ = printWithLabels profile (* 打印匹配到的 profile 及其安全标签 *)
            val _ = printString "Arya continues waiting for more matches..." (* 打印继续等待的消息 *)
          in
            receiveMatches() (* 递归调用自身，继续等待更多匹配 *)
          end,

        (* Handle all other messages *) (* 处理所有其他类型的消息 *)
        hn x => (* 当收到任何其他类型的消息时 *)
          let
            val _ = printString "Arya received an unknown message type:" (* 打印收到未知消息类型的消息 *)
            val _ = printWithLabels x (* 打印未知消息及其标签 *)
          in
            receiveMatches() (* 递归调用自身，继续等待 *)
          end
      ]
    end

  (* Define the main function to send profile *) (* 定义发送 profile 的主函数 \*)
  fun sendProfile() =
    let
      (* Create security level for profile - using proper label format *) (* 为 profile 创建安全级别 - 使用正确的标签格式 \*)
      val aryaLevel = `{arya}` (* 定义 Arya 的安全级别标签 *)4

      (* Define personal profile with security levels *) (* 定义带有安全级别的个人 profile *)
      val levelStr = "arya" raisedTo aryaLevel (* 安全级别的字符串表示 - 不再用于 profile 元组 *) (* 注意：此行代码的 `levelStr` 变量实际上未在下面的 `profile` 元组中使用 *)
      val name = "Arya Stark" raisedTo aryaLevel (* 姓名，带有 aryaLevel 标签 *)
      val year = 2105 raisedTo aryaLevel (* 出生年份，带有 aryaLevel 标签 *)
      val gender = true raisedTo aryaLevel (* 性别 - true 代表女性，带有 aryaLevel 标签 *)
      val interests = ["dragons", "wars", "fire"] raisedTo aryaLevel (* 兴趣列表，带有 aryaLevel 标签 *)

      (* Combine into profile tuple - Use aryaLevel as the first element *) (* 组合成 profile 元组 - 使用 aryaLevel 作为第一个元素 *)
      val profile = (aryaLevel, name, year, gender, interests) (* 创建包含安全级别和个人信息的 profile 元组 *)

      (* Print debug information *) (* 打印调试信息 *)
      val _ = printString "Original profile with labels:" (* 打印原始 profile 及其标签的信息 *)
      val _ = printWithLabels profile (* 打印带有标签的 profile *)

      (* Get current node identifier *) (* 获取当前节点的标识符 *)
      val thisNode = node (self ()) (* 获取当前进程运行的节点标识符 *)
      val _ = printString ("Arya running on node with identifier: " ^ thisNode) (* 打印 Arya 运行的节点标识符 *)

      (* Find server node and raise its trust level to include arya *) (* 查找服务器节点并提升其信任级别以包含 arya *)
      val serverNode = "@datingserver" (* 服务器节点的标识符 *)
      val _ = printString ("Raising trust level for server node: " ^ serverNode) (* 打印正在提升服务器节点信任级别的消息 *)
      val _ = let pini authority (* 开始一个 pini 块以获取提升信任所需的权限 *)
                 val _ = raiseTrust(serverNode, authority, aryaLevel) (* 使用 authority 提升 serverNode 的信任级别，使其能够处理 aryaLevel 的数据 *)
              in
                 printString "Successfully raised server trust level" (* 打印成功提升服务器信任级别的消息 *)
              end

      (* Spawn the receiver process FIRST and get its PID *) (* 首先创建接收进程并获取其 PID *)
      val _ = printString "Arya is spawning a process to receive match notifications..." (* 打印 Arya 正在创建接收匹配通知进程的消息 *)
      val receiverPid = spawn receiveMatches (* 创建一个新的进程来运行 receiveMatches 函数，并获取其进程 ID (PID) *)

      (* No longer declassifying profile - sending with original security levels *) (* 不再解密 profile - 使用原始安全级别发送 *)
      val _ = printString "Arya is sending her profile with original security levels to the dating server" (* 打印 Arya 正在使用原始安全级别向约会服务器发送其 profile 的消息 *)
      val _ = debugpc() (* 调用 debugpc 函数，可能用于打印当前进程的程序计数器或其他调试信息 *)

      (* Define the discovery agent to be sent. *) (* 定义要发送的发现代理 (agent) *)
      (* This version MUST NOT close over high-label data. *) (* 这个版本绝对不能捕获（close over）带有高安全标签的数据 *)
      (* It only contains the logic based on otherProfile. *) (* 它只包含基于 otherProfile 的逻辑 *)
      fun serverSideDiscoveryAgent otherProfile = (* 定义在服务器端执行的发现代理函数 *)
        (* No pini needed, no declassification happening here *) (* 这里不需要 pini，也不进行解密 *)
        let
          val (_, otherName, otherYear, otherGender, otherInterests) = otherProfile (* 从传入的 otherProfile 中解构信息（忽略第一个元素，即对方的安全级别）*)
          (* Logic specific to Arya's preferences *) (* 特定于 Arya 偏好的逻辑 *)
          val interested = otherGender = false (* 判断是否对对方感兴趣：这里 Arya 只对性别为 false (男性) 的感兴趣 *)
        in
          (* Return only boolean interest, no profile data *) (* 只返回布尔型的兴趣结果，不返回 profile 数据 *)
          if interested then
            (true, ()) (* 如果感兴趣，返回 (true, ()) *)
          else
            (false, ()) (* 如果不感兴趣，返回 (false, ()) *)
        end

    in
      (* Send profile with original security levels, the agent, AND the receiver PID *) (* 发送带有原始安全级别的 profile、agent 以及接收者 PID *)
      send(whereis("@datingserver", "datingServer"), ("NEWPROFILE", (profile, serverSideDiscoveryAgent, receiverPid))) (* 向位于 "@datingserver" 节点上名为 "datingServer" 的进程发送 "NEWPROFILE" 消息，负载包含 profile、agent 函数和接收匹配通知的进程 PID *)
    end

in
  (* Start the client by calling sendProfile *) (* 通过调用 sendProfile 启动客户端 *)
  sendProfile() (* 调用主函数来发送 profile *)
end