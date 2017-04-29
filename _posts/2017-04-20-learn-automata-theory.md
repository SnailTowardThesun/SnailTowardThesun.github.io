---
layout: article
title: learn automata theory
categories: automata
---

# 学习automata theory (自动机)

## 参考书籍
* Introduction to Automata Theory, Languages, and Computation


## 有限状态机（Finite Autolllata）

### Deterministic Finite Automata

1. defination:a `deterministic finite automata` consist of:

    1. A finite set of states, often denoted Q.
    1. A finite set of input symbols, often denoted $$\Sigma$$.
    1. A `transition function` that takes as arguments a atate and an input symbol and returns a state. Teh transition function will commonly be denoted $$\delta$$. In out informal graph representation of automata, $$\delta$$ was represented by arcs between states and the labels on the arcs. If q is a state, and a is an input symbol, then $$\delta(q, a)$$ is that state p such that there is an arc labeled a from q to $$p^2$$
    1. A start state, one of the states in Q
    1. A set of `final` or `accepting states` F. The set F is subset of Q

    A deterministic finite automaton willl often be referred to by its acronym: DFA. The most succinct representation of a DFA is a listing of the five components above. In proofs we often talk about a DFA in "five-tuple" notation:
    
     $$A=(Q,\Sigma, \delta, q_0, F)$$

    where A is the name of DFA, Q is its set of states, $$\Sigma$$ its input symbols, \delta its transition function, $$q_0$$ its start state, and F its set of acception states.