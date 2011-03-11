# vim:fileencoding=utf8
"""
 Copyright © 2011 Pádraig Brady <P@draigBrady.com>

 <!--Exclude from bashfeed-->
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
"""
import cgi
import datetime
import re
import wsgiref.handlers

#from google.appengine.api import users
from google.appengine.api import mail
from google.appengine.api import memcache
from google.appengine.ext import webapp
from google.appengine.ext import db

class Comment(db.Model):
  user = db.UserProperty()
  author = db.StringProperty()
  url = db.StringProperty()
  page = db.StringProperty(required=True)
  content = db.TextProperty()
  date = db.DateTimeProperty(auto_now_add=True)

def age(date):
  age = datetime.datetime.now() - date
  if age.days:
    return date.strftime("%d %b %Y")
  elif not age.seconds:
    return "just now"
  else:
    hours = age.seconds/3600
    if hours: return "%s hours ago" % hours
    mins = age.seconds/60
    if mins: return "%s minutes ago" % mins
    return "%s seconds ago" % age.seconds

def getcache(key, compute, time=600):
  value = memcache.get(key)
  if value is None:
    value = compute()
    memcache.set(key, value, time=time)
  return value

class MainPage(webapp.RequestHandler):
  def get(self):
    mode = self.request.get('mode')

    if mode != "count":
      self.response.out.write("""<html>
<head>
<link rel="shortcut icon" href="http://www.pixelbeat.org/favicon.ico" type="image/x-icon"/>
<!-- The following stops prefetching of domains (of urls provided by commenters) -->
<meta http-equiv="x-dns-prefetch-control" content="off">
<style type="text/css">
a { /*add :link for external links*/
    text-decoration: none; /* don't underline links by default */
    outline-style: none;   /* don't put dotted box around clicked links */
}
a:hover {
    text-decoration: underline;
}
.comment {
    background-color: #FAFAF0;
    border: 1px solid #E8E7D0;
    margin-bottom: 0.5em;
}
.odd {
    background-color: #F5F5F0;
}
</style>

<script type="text/javascript">

/* If user isn't running javascript and
   they don't click the checkbox then comment lost */
function validateOnSubmit() {

    var spammer = document.commentform.remmaps.checked;
    if (spammer==1) {
      alert("You must uncheck the checkbox");
      return false;
    }

    return true;
}
</script>
</head>
<body border=0>""")


    if mode == "count":
      value = memcache.get(self.request.path)
      if value is not None:
        self.response.out.write('%d' % value)
        return

    #TODO: can have simpler query for just counting. May not need Gql at all?
    comments = db.GqlQuery("SELECT * FROM Comment WHERE page = '%s' ORDER BY date" % self.request.path)

    if mode == "count":
      value=comments.count()
      memcache.set(self.request.path, value, 600) #timeout as can delete comments in dashboard
      self.response.out.write('%d' % value)
      return

    num=0
    for comment in comments:
      self.response.out.write('\n<div id="comment-%s" class="comment %s">\n' % (comment.key().id(), (num%2 and "odd" or "")))

      self.response.out.write('<a href="#comment-%s">#</a> ' % comment.key().id())
      if comment.author:
        if comment.url.startswith("http://"):
          self.response.out.write('<a rel="nofollow" href="%s">%s</a>:' % (cgi.escape(comment.url,quote=True), cgi.escape(comment.author)))
        else:
          self.response.out.write('%s:' % cgi.escape(comment.author))
      else:
        self.response.out.write('anonymous:')
      self.response.out.write(' ' + age(comment.date))

      self.response.out.write('\n<blockquote>%s</blockquote>' % comment.content)
      self.response.out.write('\n</div>\n')

      num+=1

    #Use this to auto fill form
    #user = users.get_current_user()
    #if user:
    #  self.response.out.write('Hello, ' + user.nickname())

    self.response.out.write("""
<div style="margin-top: 1.5em;">
<form id="commentform" name="commentform" action="" method="post" onsubmit="return validateOnSubmit();">
  <table>
  <tr><td> Name: </td> <td><input type="text" name="author" size="30"> </td></tr>
  <tr><td> Website: </td> <td><input type="text" name="url" size="60"> </td></tr>
  <tr><td> Spammer? </td> <td> <input type="checkbox" id="remmaps" name="remmaps" value="1" checked> </td></tr>
  <tr><td style="vertical-align:top;"> comments: <br/>(no HTML) </td> <td><textarea name="content" rows="10" cols="60"></textarea></td></tr>
  <table>
  <input type="submit" value="Post">
</form>
</div>
""")

    self.response.out.write('\n</html>\n</body>')

  def post(self):
    comment = Comment(page = self.request.path) #use path_qs for dynamic sites

    # google account
    #if users.get_current_user():
    #  comment.user = users.get_current_user()

    if self.request.get('remmaps'):
      self.redirect('#commentform')
      return

    comment.author = self.request.get('author')

    url = self.request.get('url')
    if "://" not in url and "@" not in url and "." in url:
      url = "http://" + url
    comment.url = url

    content = cgi.escape(self.request.get('content'))
    if not content:
      self.redirect('#commentform')
      return
    r="((?:ftp|https?)://[^ \t\n\r()\"']+)"
    content=re.sub(r,r'<a rel="nofollow" href="\1">\1</a>',content)
    content=content.replace("\n","<br/>\n")
    comment.content = db.Text(content)

    comment.put()

    # Ask client to reload ASAP
    self.redirect('#commentform')

    # Send notification email
    notification = mail.AdminEmailMessage()
    notification.sender = "pixelbeat@gmail.com" #TODO: don't hardcode
    notification.subject = (comment.author.encode("utf-8") or "anonymous") + '@' + self.request.host
    notification.body = 'http://'+self.request.host+self.request.path+'#comment-'+str(comment.key().id())
    notification.send()

def main():
  application = webapp.WSGIApplication( [('/.*', MainPage)], debug=True )
  wsgiref.handlers.CGIHandler().run(application)

if __name__ == "__main__":
  main()
