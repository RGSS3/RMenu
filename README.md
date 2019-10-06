# RMenu
Windows Explorer Menu Generator    
(1 of 100 HWonders)

## usage
```ruby
require "path\\to\\menu.rb"
clean
folder "Open with GVIMx", exe: "gvim"
group [:bg, :drive, :folder, :file], "Test Ruby", exe: "ruby", ext: ".rb", code: %{
   puts 'Hello world'
   puts ARGV[0]
   system "pause"
}, icon: "ruby"

group [".rb", ".rbw"], "run", exe: "ruby", ext: ".rb", code: %{
   system "ruby \#{ARGV[0]}"
   system "pause"
} 

basemenu :file do
   submenu "k", icon: "java,0" do
      entry "a", exe: "cmd", args: "/k echo 1", icon: "java,0"
      entry "b", exe: "cmd", args: "/k echo 2", icon: "java,0"
      submenu "l", icon: "notepad,0" do	
        entry "a", exe: "cmd", args: "/k echo 3", icon: "java,0"
        entry "b", exe: "cmd", args: "/k echo 4", icon: "java,0"
      end
  end
end
```

![test.png](test.png)

## words

Throw away your old-fashioned IDEs.    
Be companion with vim/emacs and other unique tools.    
Make your explorer a unified development environment(UDE).    

## Update Log
```
2019/10/6 Add --dry-run support, which will only show what will be executed without real executing.     
          Besides debugging purpose, you may regard it as an export to batch file form.
2019/10/6 Add basemenu, submenu, entry support
2019/10/6 Fixed some minor issues, "folder" base is replaced by "dir"
```
