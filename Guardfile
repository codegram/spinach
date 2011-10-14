guard 'minitest' do
  watch(%r|^test/(.*)_test\.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "test/#{m[1]}#{m[2]}_test.rb" }
  watch(%r|^test/test_helper\.rb|)    { "test" }
end

guard 'spinach' do
  watch(%r|^features/(.*)\.feature|)
  watch(%r|^features/steps/(.*)([^/]+)\.rb|) do |m|
    "features/#{m[1]}#{m[2]}.feature"
  end
end
