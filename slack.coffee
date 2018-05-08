module.exports = (robot) ->
  robot.respond /now_do$/, (msg) ->
    @exec = require('child_process').exec
    command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no /opt/bitnami/overwork_time/slack_notify_displayonly_for_emoto-san.sh"
    @exec command, (error, stdout, stderr) ->
      msg.send error if error?
      msg.send stdout if stdout?
      msg.send stderr if stderr?
  robot.respond /now$/, (msg) ->
    @exec = require('child_process').exec
    command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no /opt/bitnami/overwork_time/slack_notify_displayonly.sh"
    @exec command, (error, stdout, stderr) ->
      msg.send error if error?
      msg.send stdout if stdout?
      msg.send stderr if stderr?
  robot.respond /now_do ([0-9]{1,2}\/[0-9]{1,2})$/, (msg) ->
    date = msg.match[1]
    @exec = require('child_process').exec
    command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no /opt/bitnami/overwork_time/slack_notify_displayonly_for_emoto-san.sh #{date}"
    @exec command, (error, stdout, stderr) ->
      msg.send error if error?
      msg.send stdout if stdout?
      msg.send stderr if stderr?
  robot.respond /now ([0-9]{1,2}\/[0-9]{1,2})$/, (msg) ->
    date = msg.match[1]
    @exec = require('child_process').exec
    command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no /opt/bitnami/overwork_time/slack_notify_displayonly.sh #{date}"
    @exec command, (error, stdout, stderr) ->
      msg.send error if error?
      msg.send stdout if stdout?
      msg.send stderr if stderr?
  robot.respond /add (.+) (.+)$/, (msg) ->
    @exec = require('child_process').exec
    time = msg.match[1]
    if /^[0-9]+$/m.test(time) or /^[0-9]{1,2}\.[05]/m.test(time)
      reason = msg.match[2]
      name = msg.message.user.name.toLowerCase()
      today = new Date
      yyyy = today.getFullYear()
      mm = today.getMonth() + 1
      dd = today.getDate()
      if dd < 10
        dd = '0' + dd
      if mm < 10
        mm = '0' + mm
      check_register = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'grep \"#{yyyy}/#{mm}/#{dd}\" /opt/bitnami/overwork_time/#{name} >& /dev/null && echo ng || echo ok'"
      @exec check_register, (error, stdout, stderr) ->
        check = stdout.trim()
        if check is 'ok'
          if /^[0-9]+$/m.test(time)
            time = time + '.0'
          @exec = require('child_process').exec
          command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'echo #{yyyy}/#{mm}/#{dd},#{time},#{reason} >> /opt/bitnami/overwork_time/#{name}'"
          msg.send "下記内容で登録しました。\n時間外: #{time}時間\n理由: #{reason}"
          @exec command, (error, stdout, stderr) ->
            msg.send error if error?
            msg.send stdout if stdout?
            msg.send stderr if stderr?
        else
          @exec = require('child_process').exec
          check_register = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'grep \"#{yyyy}/#{mm}/#{dd}\" /opt/bitnami/overwork_time/#{name} | cut -d, -f2,3 | sed -e \"s/,/ /\"'"
          @exec check_register, (error, stdout, stderr) ->
            check = stdout.trim()
            msg.send "既に `#{check}` と登録されています。mod 等で修正してください。"
    else
      msg.send "入力内容を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
  robot.respond /mod (.+) (.+)$/, (msg) ->
    time = msg.match[1]
    reason = msg.match[2]
    name = msg.message.user.name.toLowerCase()
    today = new Date
    yyyy = today.getFullYear()
    mm = today.getMonth() + 1
    dd = today.getDate()
    if dd < 10
      dd = '0' + dd
    if mm < 10
      mm = '0' + mm
    @exec = require('child_process').exec
    check = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'grep #{yyyy}/#{mm}/#{dd} /opt/bitnami/overwork_time/#{name} >& /dev/null && echo ok || echo ng'"
    @exec check, (error, stdout, stderr) ->
      check = stdout.trim()
      if check is 'ok'
        if /^[0-9]+$/m.test(time) or /^[0-9]{1,2}\.[05]/m.test(time)
          if /^[0-9]+$/m.test(time)
            time = time + '.0'
          @exec = require('child_process').exec
          command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'sed -i -e \"s|#{yyyy}/#{mm}/#{dd}.*|#{yyyy}/#{mm}/#{dd},#{time},#{reason}|\" /opt/bitnami/overwork_time/#{name}'"
          msg.send "下記内容に変更しました。\n時間外: #{time}時間\n理由: #{reason}"
          @exec command, (error, stdout, stderr) ->
            msg.send error if error?
            msg.send stdout if stdout?
            msg.send stderr if stderr?
        else
          msg.send "入力内容を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
      else
        msg.send "まだ時間外が登録されていません。add または oadd 等で登録してください。"
  robot.respond /oadd (.+) (.+) (.+)$/, (msg) ->
    @exec = require('child_process').exec
    name = msg.match[1]
    check_name = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'ls /opt/bitnami/overwork_time/#{name} >& /dev/null && echo ok || echo ng'"
    @exec check_name, (error, stdout, stderr) ->
      check = stdout.trim()
      if check is 'ok'
        time = msg.match[2]
        if /^[0-9]+$/m.test(time) or /^[0-9]{1,2}\.[05]/m.test(time)
          reason = msg.match[3]
          today = new Date
          yyyy = today.getFullYear()
          mm = today.getMonth() + 1
          dd = today.getDate()
          if dd < 10
            dd = '0' + dd
          if mm < 10
            mm = '0' + mm
          if /^[0-9]+$/m.test(time)
            time = time + '.0'
          @exec = require('child_process').exec
          command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'echo #{yyyy}/#{mm}/#{dd},#{time},#{reason} >> /opt/bitnami/overwork_time/#{name}'"
          @exec command, (error, stdout, stderr) ->
            msg.send error if error?
            msg.send stdout if stdout?
            msg.send stderr if stderr?
          msg.send "ユーザ #{name} さんの時間外を、下記内容で登録しました。\n時間外: #{time}時間\n理由: #{reason}"
        else
          msg.send "入力内容を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
      else
        msg.send "存在しないユーザ名です。ユーザ名を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
  robot.respond /omod (.+) (.+) (.+)$/, (msg) ->
    @exec = require('child_process').exec
    name = msg.match[1]
    check_name = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'ls /opt/bitnami/overwork_time/#{name} 2>&1 > /dev/null && echo ok || echo ng'"
    @exec check_name, (error, stdout, stderr) ->
      check = stdout.trim()
      if check is 'ok'
        time = msg.match[2]
        if /^[0-9]+$/m.test(time) or /^[0-9]{1,2}\.[05]/m.test(time)
          reason = msg.match[3]
          today = new Date
          yyyy = today.getFullYear()
          mm = today.getMonth() + 1
          dd = today.getDate()
          if dd < 10
            dd = '0' + dd
          if mm < 10
            mm = '0' + mm
          if /^[0-9]+$/m.test(time)
            time = time + '.0'
          @exec = require('child_process').exec
          command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'sed -i -e \"s|#{yyyy}/#{mm}/#{dd}.*|#{yyyy}/#{mm}/#{dd},#{time},#{reason}|\" /opt/bitnami/overwork_time/#{name}'"
          @exec command, (error, stdout, stderr) ->
            msg.send error if error?
            msg.send stdout if stdout?
            msg.send stderr if stderr?
          msg.send "ユーザ #{name} さんの時間外を、下記内容に変更しました。\n時間外: #{time}時間\n理由: #{reason}"
        else
          msg.send "入力内容を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
      else
        msg.send "存在しないユーザ名です。ユーザ名を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
  robot.respond /odadd (.+) (.+) (.+) (.+)$/, (msg) ->
    @exec = require('child_process').exec
    date = msg.match[1]
    if /^[0-9]{1,2}\/[0-9]{1,2}$/m.test(date)
      if /^[0-9]{2}\/[0-9]$/m.test(date)
        date = date.replace("\/", "\/0")
      if /^[0-9]\/[0-9]{2}$/m.test(date)
        date = date.replace(/^/, "0")
      if /^[0-9]\/[0-9]$/m.test(date)
        date = date.replace(/^/, "0")
        date = date.replace("\/", "\/0")
      name = msg.match[2]
      check_name = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'ls /opt/bitnami/overwork_time/#{name} 2>&1 > /dev/null && echo ok || echo ng'"
      @exec check_name, (error, stdout, stderr) ->
        check = stdout.trim()
        if check is 'ok'
          time = msg.match[3]
          if /^[0-9]+$/m.test(time) or /^[0-9]{1,2}\.[05]/m.test(time)
            reason = msg.match[4]
            today = new Date
            yyyy = today.getFullYear()
            if /^[0-9]+$/m.test(time)
              time = time + '.0'
            @exec = require('child_process').exec
            command = "ssh -l bitnami 192.168.10.202 -oStrictHostKeyChecking=no 'echo #{yyyy}/#{date},#{time},#{reason} >> /opt/bitnami/overwork_time/#{name}'"
            @exec command, (error, stdout, stderr) ->
              msg.send error if error?
              msg.send stdout if stdout?
              msg.send stderr if stderr?
            msg.send "ユーザ #{name} さんの #{date} の時間外を、下記内容で登録しました。\n時間外: #{time}時間\n理由: #{reason}"
          else
            msg.send "入力内容を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
        else
          msg.send "存在しないユーザ名です。ユーザ名を確認してください。\n入力方法は emoto-san usage を入力し確認してください。"
  robot.respond /usage$/, (msg) ->
    msg.send "登録状況確認(通知あり): `now`\n> 現在の登録状況をPOSTします。登録していないユーザへメンションもします。\n\n
登録状況確認(通知なし): `now_do`\n> 現在の登録状況をPOSTします。\n\n
時間外登録: `add ${残業時間} ${残業理由}`\n> 時間外の登録を行います。\n\n
時間外変更: `mod ${残業時間} ${残業理由}`\n> 時間外の変更を行います。\n\n
指定ユーザの時間外登録: `oadd ${登録者SlackName} ${残業時間} ${残業理由}`\n> 指定したユーザの時間外の登録を行います。\n\n
指定ユーザの時間外変更: `omod ${登録者SlackName} ${残業時間} ${残業理由}`\n> 指定したユーザの時間外の変更を行います。\n\n
指定ユーザの、指定日の時間外登録: `odadd ${月/日} ${登録者SlackName} ${残業時間} ${残業理由}`\n> 指定したユーザの、指定日の時間外登録を行います。\n\n"
