describe command('curl http://localhost/') do
  its(:exit_status) { should eq 0 }
  its('stdout'){ should match /Admin/}
end