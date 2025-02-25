
pub fn greeting() -> String {
  "Hello, world, patch from js!" 
}

pub fn greeting_native() -> Bytes {
  let src = "Hello, World!, from native!"
  encode_utf8_cstr(src)
}

fn encode_utf8_cstr(src: String) -> Bytes {
  let bytes = @encoding.encode(UTF8, src)
  let array = bytes.to_array()
  array.push(0)
  @bytes.from_array(array)
}

pub fn say_hello() -> Unit {
  println(@lib.hello())
}