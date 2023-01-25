module Helpers::StringHelper
  AFTER_NON_REQUIRED_FILTER_WORDS = [
    'On Mon,',
    'On Tue,',
    'On Wed',
    'On Fri',
    'On Sat',
    'On Sun,',
    '> ',
    'Regards,',
    'Kind Regards',
    'Kind regards',
    'Warm Regards',
    'Warm regards',
    'Kindest Regards',
    'Kindest regards',
    'All the best',
    'Sincerely',
    'Yours truly',
    'Cheers',
    'Sent from my iPhone',
    'Get Outlook for iOS',
  ]

  ATTACHMENT_START_WITH_1 = '!['
  ATTACHMENT_START_WITH_2 = '**![]'
  
  def remove_non_required_reply(text)
    text = remove_attachment_string(text)
    text = remove_rely_text(text)

    index = nil
    
    AFTER_NON_REQUIRED_FILTER_WORDS.each do |word|
      if text.include?(word) || text.include?(word.downcase)
        index = text.index(word) || text.index(word.downcase) 
      end

      break if index.present?
    end
    
    return text[0..index-1].strip if index.present?

    text.strip
  rescue
    puts "Could not remove non required reply"

    text
  end

  private

  def remove_attachment_string(text)
    text.split(' ').delete_if { |word| word.start_with?(ATTACHMENT_START_WITH_1) || word.start_with?(ATTACHMENT_START_WITH_2) }.join(' ')
  end

  def remove_rely_text(text)
    if text.start_with?('Rely to')
      return text.split(' ')[4..-1].join(' ')
    end

    text
  end
end