def sys(*a)
   if ARGV.include?("--dry-run")
     puts a
  else
    system *a
  end
end
HEADER = "000"

def clean
  BASE.values.each{|k|
    x = `reg query HKCR\\#{k}\\Shell`.force_encoding("GBK")
    r = x.split("\n").select{|y| y["#{HEADER}."]}
    r.each{|y|
       sys "reg delete #{y} /f"
    }
  }
end
@item = 0
def put(name, opt = {})
   opt[:menuid] ||= freemenu
   regpath = opt[:regpath] || "HKCR\\*" 
   sys "REG ADD #{regpath}\\Shell\\#{opt[:menuid]} /f /v MUIVerb /t REG_SZ /d #{name.inspect}"
   if opt[:exe]
    exe = opt[:exe]
    argname = opt[:argname] || "%1"
    args = opt[:args] || "\\\"#{argname}\\\""
    exe = path_finder exe
    f = "\"\\\"#{exe}\\\" #{args}"
    sys "REG ADD #{regpath}\\Shell\\#{opt[:menuid]}\\command /f /ve /t REG_SZ /d #{f}"
   end
   if icon = opt[:icon]
     iconindex = opt[:iconindex] || "0"
     f = path_finder(icon)
     sys "REG ADD #{regpath}\\Shell\\#{opt[:menuid]} /f /v icon /t REG_SZ /d \"#{f},#{iconindex}\""
   end
   if opt[:sep_before]
     sys "REG ADD #{regpath}\\Shell\\#{opt[:menuid]} /f /v SeparatorBefore /t REG_SZ /d \"\""
   end
   if opt[:sep_after]
     sys "REG ADD #{regpath}\\Shell\\#{opt[:menuid]} /f /v SeparatorAfter /t REG_SZ /d \"\""
   end
end

MEXT = ["", ".sys", ".dll", ".ocx"]
def path_finder(name, path = ENV["path"].split(";"), ext = MEXT + ENV["pathext"].split(";"))
   path.each{|x|
      ext.each{|y|
        fname = File.expand_path(File.join x, (name + y)).tr("/", "\\")
        return fname if FileTest.file? fname
      }
   }
   name
end

BASE = {
   :file => "*",
   :dir => "directory",
   :drive => "drive",
   :bg => "directory\\background",
   :desktop => "desktopbackground"
}

def pathbase(name)
  {regpath: "HKCR\\#{BASE[name]}"}
end


BASE.keys.each{|x|
   define_method(x) do |name, opt = {}|
      put name, trans(pathbase(x).merge(opt))
   end
}

def ext e, name, opt = {}
    a = `reg query HKCR\\#{e} /ve`[/REG_SZ\s*(\S+)/, 1]
    if a
      base = {regpath: "HKCR\\#{a}"}
      put name, trans(base.update(opt))
    end
end

def bg name, opt={}
  opt[:argname] = "%V"
  put name, trans(pathbase(:bg).update(opt))
end

@path = File.expand_path(File.dirname(__FILE__)).tr("/", "\\") + "\\menu"
Dir.mkdir @path unless FileTest.directory?(@path)
@fname = 0
def trans(opt)
   argname = opt[:argname] || "%1"
   if opt[:icon] && !opt[:iconindex] && opt[:icon][","]
     r = opt[:icon].split(",")
    opt[:icon] = r[0]
    opt[:iconindex] = r[1]
   end
   if opt[:exe] && opt[:_1]
      return opt
  end
  if opt[:exe] && opt[:ext] && opt[:code]
    @fname += 1
     filename = "#{@path}\\#{@fname}#{opt[:ext]}"
     File.write filename, opt[:code]
     opt[:args] = "#{opt[:args]} \\\"#{filename}\\\" #{argname}"
     return opt
  end

  opt
end

def freemenu
   @item += 1
   sprintf "%s.%06d", HEADER, @item
end

def basemenu(a)
   @basepath = []
   @basepath.push "HKCR", BASE[a]
   yield
ensure
   @basepath.pop(2)
end

def basemenus(a)
  a.each{|n|
     basemenu n do yield end
  }
end

def submenu(a, opt = nil)
   r = freemenu
   if opt
       put a, trans({menuid: r, regpath: @basepath.join("\\")}.update(opt))
   end
   @basepath.push "shell", r
   m  = @basepath.join("\\")
   sys "REG ADD #{m} /v SubCommands /t REG_SZ /d \"\""
   yield
ensure
   @basepath.pop(2)
end

def entry name, opt = {}
   r = @basepath.join("\\")
   put name, trans({regpath: r}.update(opt))
end

def group(a, *b)
  a.each{|x|
    case x
    when Symbol
       send x, *b
    when /^\..*/
       ext x, *b
    end
  }
end

   
