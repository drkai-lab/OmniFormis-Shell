use crate::utils::expand_tilde;
use regex::Regex;
use std::collections::HashMap;
use std::fs;
use std::process::{Command, exit};

fn get_variables_path() -> std::path::PathBuf {
    expand_tilde("~/Dotfiles/quickshell/theme/variables.js")
}

pub fn load_variables() -> String {
    let path_dotfiles = get_variables_path();
    if let Ok(content) = fs::read_to_string(&path_dotfiles) {
        if !content.trim().is_empty() {
            return content;
        }
    }
    let path_config = expand_tilde("~/.config/quickshell/theme/variables.js");
    fs::read_to_string(&path_config).unwrap_or_else(|_| {
        eprintln!("Error: Could not find valid variables.js at Dotfiles or config directory");
        exit(1);
    })
}

pub fn save_variables(content: &str) {
    if content.trim().is_empty() {
        eprintln!("Error: Attempted to write empty variables.js content; aborting save.");
        return;
    }
    let path_dotfiles = get_variables_path();
    let path_config = expand_tilde("~/.config/quickshell/theme/variables.js");
    let _ = fs::write(&path_dotfiles, content);
    let _ = fs::write(&path_config, content);
}

pub fn parse_all(content: &str) -> HashMap<String, String> {
    let re = Regex::new(r"(?m)^var\s+([a-zA-Z0-9_]+)\s*=\s*(.*?);?$").unwrap();
    let mut variables = HashMap::new();
    for cap in re.captures_iter(content) {
        variables.insert(cap[1].to_string(), cap[2].trim().to_string());
    }
    variables
}

pub fn list() {
    let content = load_variables();
    let variables = parse_all(&content);

    let exclude = [
        "m3Standard", "m3StandardDecelerate", "m3StandardAccelerate",
        "m3EmphasizedDecelerate", "m3EmphasizedAccelerate",
        "m3ExpressiveSpatialFast", "m3ExpressiveSpatialSlow",
        "customStandard", "customStandardDecelerate", "customStandardAccelerate",
        "customEmphasizedDecelerate", "customEmphasizedAccelerate",
        "customExpressiveSpatialFast", "customExpressiveSpatialSlow",
    ];

    for (k, v) in variables {
        if !exclude.contains(&k.as_str()) {
            println!("{}: {}", k, v);
        }
    }
}

pub fn get(key: &str) {
    let content = load_variables();
    let variables = parse_all(&content);
    if let Some(val) = variables.get(key) {
        println!("{}", val);
    } else {
        eprintln!("Error: Variable '{}' not found.", key);
        exit(1);
    }
}

pub fn update_var(content: &str, key: &str, value: &str) -> String {
    let mut new_value_str = value.to_string();

    let pattern_get = format!(r"(?m)^(var\s+{}\s*=\s*)(.*?)(;?)$", regex::escape(key));
    let re_get = Regex::new(&pattern_get).unwrap();

    if let Some(caps) = re_get.captures(content) {
        let old_value = &caps[2];
        if old_value.starts_with('"') && old_value.ends_with('"') {
            if !(new_value_str.starts_with('"') && new_value_str.ends_with('"')) {
                new_value_str = format!("\"{}\"", new_value_str);
            }
        } else if old_value.starts_with('\'') && old_value.ends_with('\'') {
            if !(new_value_str.starts_with('\'') && new_value_str.ends_with('\'')) {
                new_value_str = format!("'{}'", new_value_str);
            }
        }
    }

    let mut result = Vec::new();
    let prefix = format!("var {} =", key);
    for line in content.lines() {
        if line.trim_start().starts_with(&prefix) {
            result.push(format!("var {} = {};", key, new_value_str));
        } else {
            result.push(line.to_string());
        }
    }
    result.join("\n") + "\n"
}

pub fn set(key: &str, value: &str) {
    let content = load_variables();
    let variables = parse_all(&content);
    
    if !variables.contains_key(key) {
        eprintln!("Error: Variable '{}' not found.", key);
        exit(1);
    }

    let new_content = update_var(&content, key, value);
    save_variables(&new_content);
    println!("Set '{}' to {}", key, value);
}

pub fn kill() {
    println!("Killing Quickshell...");
    let _ = Command::new("sh")
        .arg("-c")
        .arg("pkill -9 quickshell; pkill -9 .quickshell-wra; pkill -f qs-watchdog")
        .status();
}

pub fn launch(detached: bool) {
    println!("Launching Quickshell...");
    if detached {
        let _ = Command::new("sh")
            .arg("-c")
            .arg("nohup bash /home/boing/Dotfiles/quickshell/scripts/qs-watchdog.sh > /dev/null 2>&1 &")
            .spawn();
    } else {
        let _ = Command::new("bash")
            .arg("/home/boing/Dotfiles/quickshell/scripts/qs-watchdog.sh")
            .status();
    }
}

pub fn reload() {
    println!("Reloading Quickshell...");
    let _ = Command::new("sh")
        .arg("-c")
        .arg("bash /home/boing/Dotfiles/scripts/reload.sh")
        .status();
}

