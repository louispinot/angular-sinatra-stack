new_feedback = lambda do
  feedback = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.feedbacks.create(feedback_type: feedback[:feedbackType], feedback_body: feedback[:feedbackText])

  Publisher.simple_publish('hub_email', {
                                   email_type: :feedback,
                                   args: {
                                       from: user.email,
                                       feedback_type: feedback[:feedbackType],
                                       feedback_body: feedback[:feedbackText]
                                   }
                               }.to_json)

status 200

end

post '/feedback/submit', &new_feedback
