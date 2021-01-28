---
layout: post
title: 'What is Ruby String.length time complexity?'
date: 2021-01-27 22:30:00
categories: ['ruby']
---

I've been asking myself this question: is Ruby `String.length` like C `strlen` which is `O(n)`? In order to find it I've decided to dive into the
Ruby MRI source code (which is written in C).

Here's the source code of ruby `String.length` (at the time of writing this article):

```c
VALUE
rb_str_length(VALUE str)
{
    return LONG2NUM(str_strlen(str, NULL));
}
```

As you can see it a calls `str_strlen` and then calls `LONG2NUM` on the results, what `LONG2NUM` does
is just to convert a `C long int` into a ruby `Numeric` class.
At this point let's see what `str_strlen` does:

<pre>
static long
str_strlen(VALUE str, rb_encoding *enc)
{
    const char *p, *e;
    int cr;

    <strong>if (single_byte_optimizable(str)) return RSTRING_LEN(str);</strong>
    if (!enc) enc = STR_ENC_GET(str);
    p = RSTRING_PTR(str);
    e = RSTRING_END(str);
    cr = ENC_CODERANGE(str);

    if (cr == ENC_CODERANGE_UNKNOWN) {
	long n = rb_enc_strlen_cr(p, e, enc, &cr);
	if (cr) ENC_CODERANGE_SET(str, cr);
	return n;
    }
    else {
	return enc_strlen(p, e, enc, cr);
    }
}
</pre>

What you should focus on is just the bold text, which is what usually runs (except if the string is encoded in a
multi-byte encoding). If you take a look all is does is to call `RSTRING_LEN(str)`:

```
#define RSTRING_LEN(string) RSTRING(string)->len
```

The above is a C macro which just fetches len from a `RString` struct. In fact every Ruby string is
stored in a `RString` struct, which contains meaningful informations such as the current length of the
String:

```c
struct RString {
    struct RBasic basic;
    union {
        struct {
            long len;
            char *ptr;
            union {
                long capa;
                VALUE shared;
            } aux;
        } heap;
        char ary[RSTRING_EMBED_LEN_MAX + 1];
    } as;
};
```

Now that you've seen how it works I think you already know the answer: the time complexity to read a
String length in ruby is `O(1)` constant time, unless we are saving a string in a multi byte
encoding which cannot benefit from the `single_byte_optimizable` feature. In that case we have a
performance degradation to `O(n)`.

Below some benchmarks which shows this:

```ruby
require 'benchmark/ips'

optimizable = "this is a string" * 10_000
not_optimizable = "this is â string" * 10_000

Benchmark.ips do |x|
  x.report("optimizable") { optimizable.length }
  x.report("not optimizable") { not_optimizable.length }
  x.compare!
end

```

result:

```
Calculating -------------------------------------
         optimizable   268.816k i/100ms
     not optimizable     7.570k i/100ms
-------------------------------------------------
         optimizable     28.189M (± 4.8%) i/s -    140.322M
     not optimizable     76.836k (± 5.8%) i/s -    386.070k

Comparison:
         optimizable: 28188582.0 i/s
     not optimizable:    76836.2 i/s - 366.87x slower
```

As you can see just by using a 160000 length string the optimized `O(1)` version is 366 times faster,
the longer is the string compared the faster will be the optimized version due to the different time
complexity.
