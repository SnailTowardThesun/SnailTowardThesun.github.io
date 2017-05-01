---
layout: article
title: learn automata theory
categories: automata
---

# 学习automata theory (自动机)

## 参考书籍
* Introduction to Automata Theory, Languages, and Computation


## 有限状态机（Finite Automata）

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

### NonDeterministic Finite Automata
1. defination: an NFA is represented essentially like a DFA:

    $$
    A = (Q, \Sigma, \delta, q_0, F)
    $$

    where:
    1. Q is a finite set of states
    1. $$\Sigma$$ is a finite set of input symblos.
    1. $$q_0$$, a member of Q, is the start state
    1. F, a subset of Q, is the set of final (or accepting) states.
    1. $$\delta$$, the transition function is a function that takes a state in Q and an input symbol in $$\Sigma$$ as arguments and returns a subset of Q. Notice that the only difference between an NFA and DFA is in the type of value that $$\delta$$ returns: a set of states in the case of an NFA and a single state in the case of DFA.

### $$\epsilon$$-NFA
1. defination: 

    we may represent an $$\epsilon$$-NFA exactly as we do an NFA, with one exception: the transition function must include information about transitions on $$\epsilon$$. Formally, we represent an $$\epsilon$$-NFA A by $$A=(Q, \Sigma, \delta, q_0, F)$$, where all components have their same interpretation as for an NFA, except that $$\delta$$ is now a function that takes as arguments:
    1. A state in Q, and
    1. A member of $$\Sigma \cup {\epsilon}$$, that is either an input symbol, or the symbol $$\epsilon$$. We require that $$\epsilon$$, the symbol for the empty string, cannot be a member of alphabet $$\Sigma$$, the symbol for the empty string, cannot be a member of the alphabet $$\Sigma$$, so no confusion results.