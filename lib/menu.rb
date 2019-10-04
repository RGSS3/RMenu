def clean
  ["Directory", "Folder", "*"].each{|k|
    x = `reg query HKCR\\#{k}\\Shell`
    r = x.split("\n").select{|y| y["mymenu."]}
    r.each{|y|
       system "reg delete #{y} /f"
    }
  }
end
@item = 0
def put(item, name, opt = {})
   @item += 1
   exe = opt[:exe]
   argname = opt[:argname] || "%1"
   args = opt[:args] || "\\\"#{argname}\\\""
   exe = `where.exe #{exe}`.gsub(/\n/, "")
   f = "\"\\\"#{exe}\\\" #{args}"
   system "REG ADD HKCR\\#{item}\\Shell\\mymenu.#{@item} /f /ve /t REG_SZ /d #{name.inspect}"
   system "REG ADD HKCR\\#{item}\\Shell\\mymenu.#{@item}\\command /f /ve /t REG_SZ /d #{f}"
   if icon = opt[:icon]
     iconindex = opt[:iconindex] || "0"
     f = File.expand_path(`where #{icon}`.gsub(/\n/, "")).tr("/", "\\")
     system "REG ADD HKCR\\#{item}\\Shell\\mymenu.#{@item} /f /v icon /t REG_SZ /d \"#{f},#{iconindex}\""
   end
end

def folder name, opt = {}
   put "folder", name, trans(opt)
end

def file name, opt = {}
  put "*", name, trans(opt)
end

def dir name, opt={}
  put "directory", name, trans(opt)
end

def drive name, opt={}
  put "drive", name, trans(opt)
end

def bg name, opt={}
  opt[:argname] = "%V"
  put "Directory\\Background", name, trans(opt)
end

@path = File.expand_path(File.dirname(__FILE__)).tr("/", "\\") + "\\menu"
Dir.mkdir @path unless FileTest.directory?(@path)
@fname = 0
def trans(opt)
   argname = opt[:argname] || "%1"
   if opt[:exe] && opt[:_1]
      return opt
  end
  if opt[:exe] && opt[:ext] && opt[:code]
    @fname += 1
     filename = "#{@path}\\#{@fname}#{opt[:ext]}"
     File.write filename, opt[:code]
     opt[:args] = "\\\"#{filename}\\\" \\\"#{argname}\\\""
     return opt
  end

  opt
end

def group(a, *b)
  a.each{|x|
    send x, *b
  }
end

   
