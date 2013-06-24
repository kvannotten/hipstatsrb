module ApplicationHelpers
  def render(*args)
   if args.first.is_a?(Hash) and args.first.keys.include?(:partial)
     return erb "partials/_#{args.first[:partial]}".to_sym, args.first.merge!(:layout => false)
   elsif args.first.is_a?(Hash) and args.first.keys.include?(:chart)
     return erb "partials/charts/_#{args.first[:chart]}".to_sym, args.first.merge!(:layout => false)
   else
     super
   end
  end
end