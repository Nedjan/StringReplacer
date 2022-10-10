require 'json'

def lambda_handler(event:, context:)
    params = event['queryStringParameters']
    query = params['query'] unless params.nil?

    return { statusCode: 200, body: JSON.generate({ result: '' }) } if query.nil?

    return { statusCode: 422, body: JSON.generate({ error: 'Expected a string parameter' }) } unless query.is_a? String

    default_dictionary = {
        'Oracle': 'Oracle©',
        'Google': 'Google©',
        'Microsoft': 'Microsoft©',
        'Amazon': 'Amazon©',
        'Deloitte': 'Deloitte©'
    }
    dictionary = JSON.parse(ENV['dictionary']) || default_dictionary

    dictionary.each_key do |key|
        # this regex captures full words only. Ignores words like "Amazons"
        # case sensitive
        query.gsub!(/\b#{key}\b/, dictionary[key])
    end

    { statusCode: 200, body: JSON.generate({ result: query }) }
end
