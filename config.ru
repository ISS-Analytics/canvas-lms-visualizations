Dir.glob('./{models,helpers,services,values,.}/*.rb')
  .each do |file|
  require file
end

run CanvasLmsAPI
