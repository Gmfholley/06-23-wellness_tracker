var score = 0;


function toggle_pop_up_menu(){
  document.getElementById("pop-up-menu").classList.toggle("pop-up-menu-hidden");
  document.getElementById("pop-up-menu").classList.toggle("pop-up-menu-shown");
}



window.onload = function(){
  document.getElementById("menu-icon").addEventListener("click", toggle_pop_up_menu);
}