Friendship.destroy_all
Chat.destroy_all
User.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('users')

def create_users
    User.create(username: "Test User1", email: "test.email1@mail.com", password: "password")
    User.create(username: "Test User2", email: "test.email2@mail.com", password: "password")
    User.create(username: "Test User3", email: "test.email3@mail.com", password: "password")
    User.create(username: "John Doe", email: "johndoe@mail.com", password: "password")
    User.create(username: "Jane Doe", email: "janedoe@mail.com", password: "password")
    User.create(username: "Robert Barret", email: "robertbarret@mail.com", password: "password")
    User.create(username: "Jack Khan", email: "jackhkan@mail.com", password: "password")
    User.create(username: "Henry Simpson", email: "henrysimpson@mail.com", password: "password")
    User.create(username: "Hayden Harper", email: "haydenharper@mail.com", password: "password")
    User.create(username: "Jack Kennedy", email: "jackkennedy@mail.com", password: "password")
    User.create(username: "Memphis Valenzuela", email: "mempisvelzuela@mail.com", password: "password")
    User.create(username: "Camdyn Daniel", email: "camdydaniel@mail.com", password: "password")
    User.create(username: "Braylon Wiggins", email: "braylonwiggins@mail.com", password: "password")
    User.create(username: "Micah Hayes", email: "micahhayes@mail.com", password: "password")
    User.create(username: "Darwin Aguilar", email: "darwinaguliar@mail.com", password: "password")
    User.create(username: "Anthony Cook", email: "anthonycook@mail.com", password: "password")
    User.create(username: "Zaid Davidsons", email: "zaiddavidson@mail.com", password: "password")
    User.create(username: "Alfie Fisher", email: "alfiefisher@mail.com", password: "password")
    User.create(username: "Adan Head", email: "adanhead@mail.com", password: "password")
    User.create(username: "Zachary Chapman", email: "zacharychapman@mail.com", password: "password")
    User.create(username: "William Chapman", email: "williamchapman@mail.com", password: "password")
    User.create(username: "Tyler Pearce", email: "tylerpearce@mail.com", password: "password")
    User.create(username: "Tommy Sharp", email: "tomysharp@mail.com", password: "password")
    User.create(username: "Emily Wilson", email: "emilywilson@mail.com", password: "password")
    User.create(username: "Alexander Garcia", email: "alexandergarcia@mail.com", password: "password")
  end
  
  def create_public_chats
    Chat.create(type: 'public', name: 'Football')
    Chat.create(type: 'public', name: 'Basketball')
    Chat.create(type: 'public', name: 'Gaming')
    Chat.create(type: 'public', name: 'Programming')
    Chat.create(type: 'public', name: 'Travel')
    Chat.create(type: 'public', name: 'Jokes')
    Chat.create(type: 'public', name: 'Science')
    Chat.create(type: 'public', name: 'Engineering')
    Chat.create(type: 'public', name: 'World News')
    Chat.create(type: 'public', name: 'Music')
    Chat.create(type: 'public', name: 'Economics')
    Chat.create(admin_id: User.first.id, type: 'public', name: 'User1 chat')
    Chat.create(admin_id: User.second.id, type: 'public', name: 'User2 chat')
    Chat.create(admin_id: User.third.id, type: 'public', name: 'User3 chat')

    Chat.first.image.attach(io: File.open("#{Rails.root}/app/assets/images/football.jpg"), filename: 'football.jpg' , content_type: 'image/jpg')
    Chat.second.image.attach(io: File.open("#{Rails.root}/app/assets/images/basketball.jpg"), filename: 'basketball.jpg' , content_type: 'image/jpg')
    Chat.third.image.attach(io: File.open("#{Rails.root}/app/assets/images/gaming.jpg"), filename: 'gaming.jpg' , content_type: 'image/jpg')
    Chat.fourth.image.attach(io: File.open("#{Rails.root}/app/assets/images/programming.jpg"), filename: 'programming.jpg' , content_type: 'image/jpg')

    public_chats = Chat.all
    public_chats.each do |chat|
      User.all.sample(rand(15..35)).each do |user|
        chat.chat_participants.create(participant_id: user.id)
      end
    end
    public_chats.each do |chat|
      rand(2..20).times do
        chat.messages.create(body: generate_random_text, user_id: chat.participants.sample.id)
      end
    end
  end

  def create_friendships
    users = [User.first, User.second, User.third]
    users.each do |user|
      User.all.to_a.sample(rand(5..15)).each do |friend|
        next if user.id == friend || Friendship.where(user_id: user.id).where(friend_id: friend).any?
        Friendship.create(user_id: user.id, friend_id: friend.id)
        Friendship.create(user_id: friend.id, friend_id: user.id)
        chat = Chat.create(type: 'direct')
        chat.chat_participants.create(participant_id: user.id)
        chat.chat_participants.create(participant_id: friend.id)
        rand(0..15).times do
            chat.messages.create(body: generate_random_text, user_id: chat.participants.sample.id)
          end
      end
    end
  end

  def create_friend_requests
    users = [User.first, User.second, User.third]
    users.each do |user|
      User.all.to_a.sample(rand(5..10)).each do |friend|
        next if user.id == friend || Friendship.where(user_id: user.id).where(friend_id: friend).any?|| FriendRequest.where(sender_id: friend.id).where(reciever_id: user).any?
        FriendRequest.create(sender_id: friend.id, reciever_id: user.id)
      end
    end
  end
  
  @lorem_ipsum_text = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis lobortis tincidunt nulla, quis mollis nibh sodales non. Sed eget tempus eros, at eleifend sem. Sed suscipit semper varius.",
    "Quisque luctus",
    "feugiat tempus.",
    "Pellentesque mollis",
    "Set odio",
    "nec aliquet.",
    "Aliquam in condimentum lectus.",
    "Curabitur tellus" ,
    "dui, vestibulum at elit sit amet",
    "Fermentum consequat purus.",
    "Vivamus quis lacinia tortor.",
    "Donec ut viverra nunc.",
    "Duis suscipit vel quam quis rhoncus.",
    "Praesent gravida",
    "arcu nec sapien pellentesque posuere.",
    "Nunc consectetur tempus pharetra.",
    "Aliquam vulputate ante non justo vulputate, et bibendum lacus malesuada.",
    "In ante tellus, ultrices in gravida sagittis, convallis in quam. Suspendisse semper quis metus ac viverra. Nulla lobortis viverra est non malesuada.",
    "Nunc quis eleifend felis. Proin fringilla, arcu commodo vehicula viverra, lorem erat imperdiet ligula, id egestas diam dolor vel mauris.",
    "Nullam ultrices dapibus tempor. In iaculis mi rhoncus tortor malesuada aliquet. Cras velit mauris, volutpat id sagittis at, porttitor sed justo.",
    "Vivamus molestie tortor ut magna maximus congue. Vivamus quis posuere lectus. Nulla non ornare ipsum, vel egestas massa.",
    "Nam ultrices, nibh at venenatis convallis, erat orci blandit lorem, quis lacinia orci sem a nisi. Etiam est ex, mattis in pretium id, blandit vitae enim.",
    "Mauris sed sollicitudin sapien, non auctor nulla. Fusce a nibh euismod, lobortis ante ut, laoreet dui. Quisque vitae sem rhoncus, vehicula nunc id, commodo mi.",
    "Sed mattis efficitur finibus. Sed efficitur fringilla nulla, id iaculis tellus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
    "Nunc vulputate eros massa, non rhoncus ipsum accumsan non. Donec metus elit, eleifend ultricies eros nec, faucibus interdum nisi.",
  ]
  
  def generate_random_text
      @lorem_ipsum_text.sample
  end
  
  create_users
  create_public_chats
  create_friendships
  create_friend_requests